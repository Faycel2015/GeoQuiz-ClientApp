import 'dart:math';

import 'package:app/models/models.dart';
import 'package:app/services/local_progression_service.dart';
import 'package:app/services/sqlite_helper.dart';
import 'package:app/ui/homepage/homepage.dart';
import 'package:app/utils/database_content_wrapper.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';



/// Repository to manage local data in the user device.
/// It handles the static and dynamic data :
///   - static data are : themes and questions
///   - dynamic data are : local progression
abstract class ILocalDatabaseRepository {

  /// Get the current version of the local database
  /// return null if the database is not yet created
  /// TODO: never returned an exception
  Future<int> currentDatabaseVersion();

  /// Update the static part of the database (themes, questions)
  Future<void> updateStaticDatabase(int version, DatabaseContentWrapper databaseContentContainer);

  /// Get all themes
  Future<List<QuizTheme>> getThemes();

  /// Get list of questions
  /// [count] is the number of questions to return
  Future<List<QuizQuestion>> getQuestions({int count, Iterable<QuizTheme> themes, DifficultyData difficulty});
}



/// [ILocalDatabaseRepository] that use SQLite to manage the data.
/// It uses the sqflite package https://pub.dev/packages/sqflite (in particular  
/// see current issues when adding new features to make sure it is supported)
class SQLiteLocalDatabaseRepository implements ILocalDatabaseRepository {

  final Logger logger;
  
  final SQLiteHelper database = SQLiteHelper();
  final ILocalProgressionRepository localProgressionRepo;

  SQLiteLocalDatabaseRepository(this.logger, {
    @required this.localProgressionRepo
  });

  /// Open the database, get the version
  /// if the version is equals to 0 it returns null (no database)
  @override
  Future<int> currentDatabaseVersion() async {
    var v = await database.getVersion();
    logger.i("Local database version $v");
    return v == 0 ? null : v;
  }


  /// Reinit the database (DROP and CREATE tables), and then add all questions
  /// and themes (wrapped in a [DatabaseContentWrapper]) to the database
  @override
  Future<void> updateStaticDatabase(int version, DatabaseContentWrapper wrapper) async {
    var db = await database.open(version: version);

    await database.deleteTheme(db);
    await database.deleteQuestions(db);

    var batch = db.batch();
    for (var t in wrapper.themes??[]) {
      batch.insert(LocalDatabaseIdentifiers.THEMES_TABLE, _LocalThemeAdapter.toMap(t));
    }
    for (var q in wrapper.questions??[]) {
      batch.insert(LocalDatabaseIdentifiers.QUESTIONS_TABLE, _LocalQuestionAdapter.toMap(q));
    }
    try {
      var result = await batch.commit(continueOnError: true);
      logger.i("Updated. " + result.where((r) => r is DatabaseException).length.toString() + " errors");
      logger.i("New local version : $version");
    } catch (e) { // if nothing is commit, we reset the version to 0
      await db.setVersion(0);
      logger.e("$e");
      return Future.error(e);
    }
    await db.close();
  }


  /// Returns the list of themes
  @override
  Future<List<QuizTheme>> getThemes() async {
    var db = await database.open();
    var themes = List<QuizTheme>();
    var themesData = await db.query(LocalDatabaseIdentifiers.THEMES_TABLE);
    for (var t in themesData) {
      themes.add(_LocalThemeAdapter(data: t));
    }
    await db.close();
    return themes;
  }


  /// Get a list of questions of maximum [count] elements and where the themes
  /// of the questions are in [themes] collection.
  /// 
  /// If we are in an automatic mode we chose questions the easier questions
  /// not answered correctly
  @override
  Future<List<QuizQuestion>> getQuestions({int count, Iterable<QuizTheme> themes, DifficultyData difficulty}) async {    
    final db = await database.open();
    final themeIDs = themes.map((t) => "'${t.id}'").toList(); // list of the ID surouned by the "'" character
    
    var baseQuery = '''
      FROM ${LocalDatabaseIdentifiers.QUESTIONS_TABLE}
      WHERE ${LocalDatabaseIdentifiers.QUESTION_THEME} IN (${themeIDs.join(',')})
    ''';

    if (difficulty.automatic) { 
      final answeredQuestion = await db.rawQuery('''
        SELECT ${LocalDatabaseIdentifiers.QUESTION_ID}
        FROM ${LocalDatabaseIdentifiers.QUESTIONS_TABLE} A
        INNER JOIN ${LocalDatabaseIdentifiers.PROGRESSIONS_TABLE} B
        ON A.${LocalDatabaseIdentifiers.QUESTION_ID} = B.${LocalDatabaseIdentifiers.PROGRESSION_QUESTION}
        WHERE A.${LocalDatabaseIdentifiers.QUESTION_THEME} IN (${themeIDs.join(',')})
        ORDER BY RANDOM()
      '''); //  immutable and unmodifiable list
    
      final listQuestionsID = answeredQuestion.map((q) => "'${q[LocalDatabaseIdentifiers.QUESTION_ID]}'").toList();
      // we remove some questions of the list to improve to let the user play with questions that he already answered
      listQuestionsID.removeRange(0, (answeredQuestion.length / 3).round());
      baseQuery += "AND ${LocalDatabaseIdentifiers.QUESTION_ID} NOT IN (${listQuestionsID.join(",")})";
    }

    var countQuestionQuery = await db.rawQuery('''
      SELECT COUNT(*)
      $baseQuery
    ''');
    var countTotal = Sqflite.firstIntValue(countQuestionQuery);

    var lowerBound = 0;
    if (!difficulty.automatic)
      lowerBound = min(countTotal - count, (difficulty.difficultyChose / 100 * countTotal).round());
    var upperBound = lowerBound + count;

    final questionsQuery = await db.rawQuery('''
      SELECT *
      $baseQuery
      ORDER BY ${LocalDatabaseIdentifiers.QUESTION_DIFFICULTY}, RANDOM()
      LIMIT $lowerBound, $upperBound
    ''');

    final questions = List<QuizQuestion>();
    for (var q in questionsQuery) {
      try {
        var t = themes.where((t) => t.id == q[LocalDatabaseIdentifiers.QUESTION_THEME]).first;
        questions.add(_LocalQuestionAdapter(data: q, theme: t));
      } catch (e) { }
    }
    await db.close();
    return questions;
  }
}



/// Adapter to adapt SQL data ([Map]) to [QuizTheme]
/// 
/// See [SQLiteLocalDatabaseRepository._reinitDatabase] to see the SQL data 
/// types.
/// 
/// It is also used to do the reverse direction transformation (QuizTheme to SQL 
/// data) but as SQL data is respresented by a [Map<String, dynamic] it is too 
/// painful to implements [Map] as there are a lot of methods. Instead there is 
/// simply the static method [toMap] that take a [QuizTheme] and return the 
/// [Map].
class _LocalThemeAdapter extends QuizTheme  {

  _LocalThemeAdapter({@required Map<String, Object> data}) {
    this.id = data[LocalDatabaseIdentifiers.THEME_ID];
    this.title = data[LocalDatabaseIdentifiers.THEME_TITLE];
    this.icon = data[LocalDatabaseIdentifiers.THEME_ICON];
    this.color = data[LocalDatabaseIdentifiers.THEME_COLOR];
    this.entitled = data[LocalDatabaseIdentifiers.QUESTION_ENTITLED];
  }

  static Map<String, dynamic> toMap(QuizTheme theme) =>
    {
      LocalDatabaseIdentifiers.THEME_ID: theme.id,
      LocalDatabaseIdentifiers.THEME_TITLE: theme.title,
      LocalDatabaseIdentifiers.THEME_ICON: theme.icon,
      LocalDatabaseIdentifiers.THEME_COLOR: theme.color,
      LocalDatabaseIdentifiers.THEME_ENTITLED: theme.entitled
    };
}



/// Adapter to adapt SQL data ([Map]) to [QuizQuestion]
/// 
/// See [SQLiteLocalDatabaseRepository._reinitDatabase] to see the SQL data 
/// types.
/// 
/// It is also used to do the reverse direction transformation (QuizQuestion to 
/// SQL data) but as SQL data is respresented by a [Map<String, dynamic] it is 
/// too painful to implements [Map] as there are a lot of methods. Instead there 
/// is simply the static method [toMap] that take a [QuizQuestion] and return 
/// the [Map].
class _LocalQuestionAdapter extends QuizQuestion {

  static const serializationCharacter = "##";
  static const typeTxt = "txt";
  static const typeImg = "img";
  static const typeLoc = "loc";

  _LocalQuestionAdapter({@required QuizTheme theme, @required Map<String, Object> data}) {
    this.id = data[LocalDatabaseIdentifiers.QUESTION_ID];
    this.theme = theme;

    final _entitled = data[LocalDatabaseIdentifiers.QUESTION_ENTITLED];
    final _entitledType = _strToType(data[LocalDatabaseIdentifiers.QUESTION_ENTITLED_TYPE]);
    this.entitled = Resource(resource: _entitled, type: _entitledType);

    final _answersStr = (data[LocalDatabaseIdentifiers.QUESTION_ANSWERS] as String);
    final _answers = _answersStr.split(serializationCharacter);
    final _answersType = _strToType(data[LocalDatabaseIdentifiers.QUESTION_ANSWERS_TYPE]);
    this.answers = _answers.map(
      (a) => QuizAnswer(answer: Resource(resource: a, type: _answersType))
      ).toList();
    this.answers.first.isCorrect = true;

    this.difficulty = data[LocalDatabaseIdentifiers.QUESTION_DIFFICULTY];
  }

  static Map<String, dynamic> toMap(QuizQuestion question) {
    var answers = question.answers.map((a) => a.answer.resource).join(serializationCharacter);
    var answersType = _typeToStr(question.answers.first.answer.type);
    return {
      LocalDatabaseIdentifiers.QUESTION_ID: question.id,
      LocalDatabaseIdentifiers.QUESTION_THEME: question.theme.id,
      LocalDatabaseIdentifiers.QUESTION_ENTITLED: question.entitled.resource,
      LocalDatabaseIdentifiers.QUESTION_ENTITLED_TYPE: _typeToStr(question.entitled.type),
      LocalDatabaseIdentifiers.QUESTION_ANSWERS: answers,
      LocalDatabaseIdentifiers.QUESTION_ANSWERS_TYPE: answersType,
      LocalDatabaseIdentifiers.QUESTION_DIFFICULTY: question.difficulty,
    };
  }

  static ResourceType _strToType(String typeStr) {
    switch (typeStr) {
      case typeTxt : return ResourceType.text;
      case typeImg : return ResourceType.image;
      case typeLoc : return ResourceType.location;
      default: throw("Not supported type");
    }
  }

  static String _typeToStr(ResourceType type) {
    switch (type) {
      case ResourceType.text: return typeTxt;
      case ResourceType.image: return typeImg;
      case ResourceType.location: return typeLoc;
      default: throw("Not supported type");
    }
  }
}