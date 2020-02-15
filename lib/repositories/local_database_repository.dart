import 'package:app/models/models.dart';
import 'package:app/utils/database_content_wrapper.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';



/// Repository to manage local data in the user device.
/// It handles the static and dynamic data :
///   - static data are : themes and questions
///   - dynamic data are : local progression
abstract class LocalDatabaseRepository {

  /// Get the current version of the local database
  /// return null if the database is not yet created
  Future<int> currentDatabaseVersion();

  /// Update the static part of the database (themes, questions)
  Future<void> updateStaticDatabase(int version, DatabaseContentWrapper databaseContentContainer);

  /// Get all themes
  Future<List<QuizTheme>> getThemes();

  /// Get list of questions
  /// [count] is the number of questions to return
  Future<List<QuizQuestion>> getQuestions({int count, Iterable<QuizTheme> themes});
}



/// [LocalDatabaseRepository] that use SQLite to manage the data.
/// It uses the sqflite package https://pub.dev/packages/sqflite (in particular  
/// see current issues when adding new features to make sure it is supported)
class SQLiteLocalDatabaseRepository implements LocalDatabaseRepository {

  /// Open the database, get the version
  /// if the version is equals to 0 it returns null (no database)
  @override
  Future<int> currentDatabaseVersion() async {
    var _db = await openDatabase(_Identifiers.DATABASE_NAME);
    var v = await _db.getVersion();
    await _db.close();
    return v == 0 ? null : v;
  }


  /// Reinit the database (DROP and CREATE tables), and then add all questions
  /// and themes (wrapped in a [DatabaseContentWrapper]) to the database
  @override
  Future<void> updateStaticDatabase(int version, DatabaseContentWrapper wrapper) async {
    var db = await openDatabase(_Identifiers.DATABASE_NAME, version: version);

    await _reinitDatabase(db);

    var batch = db.batch();
    for (var t in wrapper.themes??[]) {
      batch.insert(_Identifiers.THEMES_TABLE, _LocalThemeAdapter.toMap(t));
    }
    for (var q in wrapper.questions??[]) {
      batch.insert(_Identifiers.QUESTIONS_TABLE, _LocalQuestionAdapter.toMap(q));
    }
    try {
      var result = await batch.commit(continueOnError: true);
      print(result.where((r) => r is DatabaseException).length.toString() + " errors");
    } catch (e) { // if nothing is commit, we reset the version to 0
      await db.setVersion(0);
      return Future.error(e);
    }
    await db.close();
  }


  /// Returns the list of themes
  @override
  Future<List<QuizTheme>> getThemes() async {
    var db = await openDatabase(_Identifiers.DATABASE_NAME);
    var themes = List<QuizTheme>();
    var themesData = await db.query(_Identifiers.THEMES_TABLE);
    for (var t in themesData) {
      themes.add(_LocalThemeAdapter(data: t));
    }
    await db.close();
    return themes;
  }


  /// Get a list of questions of maximum [count] elements and where the themes
  /// of the questions are in [themes] collection.
  @override
  Future<List<QuizQuestion>> getQuestions({int count, Iterable<QuizTheme> themes}) async {
    final db = await openDatabase(_Identifiers.DATABASE_NAME);
    final themeIDs = themes.map((t) => "'${t.id}'").toList(); // list of the ID surouned by the "'" character
    
    final rawQuestions = await db.query(
      _Identifiers.QUESTIONS_TABLE, 
      limit: count,
      where: "${_Identifiers.QUESTION_THEME} IN (${themeIDs.join(',')})",
      orderBy: "RANDOM()"
    );

    final questions = List<QuizQuestion>();
    for (var q in rawQuestions) {
      try {
        var t = themes.where((t) => t.id == q[_Identifiers.QUESTION_THEME]).first;
        questions.add(_LocalQuestionAdapter(data: q, theme: t));
      } catch (e) { }
    }
    await db.close();
    return questions;
  }


  /// Drop the static tables (questions, themes)
  /// and recreate theme completly
  Future<void> _reinitDatabase(Database db) async {
    await db.execute("DROP TABLE IF EXISTS ${_Identifiers.THEMES_TABLE};");
    await db.execute("DROP TABLE IF EXISTS ${_Identifiers.QUESTIONS_TABLE};");
    await db.execute('''
      CREATE TABLE ${_Identifiers.THEMES_TABLE} (
        ${_Identifiers.THEME_ID} text primary key,
        ${_Identifiers.THEME_TITLE} text not null,
        ${_Identifiers.THEME_ICON} text not null,
        ${_Identifiers.THEME_COLOR} int not null,
        ${_Identifiers.THEME_ENTITLED} text not null
      )
    ''');
    await db.execute('''
      CREATE TABLE ${_Identifiers.QUESTIONS_TABLE} (
        ${_Identifiers.QUESTION_ID} text primary key,
        ${_Identifiers.QUESTION_THEME} text not null,
        ${_Identifiers.QUESTION_ENTITLED} text not null,
        ${_Identifiers.QUESTION_ENTITLED_TYPE} text not null,
        ${_Identifiers.QUESTION_ANSWERS} text not null,
        ${_Identifiers.QUESTION_ANSWERS_TYPE} text not null,
        ${_Identifiers.QUESTION_DIFFICULTY} int not null
      )
    ''');
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
class _LocalThemeAdapter implements QuizTheme  {
  String id;
  String title;
  String icon;
  int color;
  String entitled;

  _LocalThemeAdapter({@required Map<String, Object> data}) {
    this.id = data[_Identifiers.THEME_ID];
    this.title = data[_Identifiers.THEME_TITLE];
    this.icon = data[_Identifiers.THEME_ICON];
    this.color = data[_Identifiers.THEME_COLOR];
    this.entitled = data[_Identifiers.QUESTION_ENTITLED];
  }

  static Map<String, dynamic> toMap(QuizTheme theme) =>
    {
      _Identifiers.THEME_ID: theme.id,
      _Identifiers.THEME_TITLE: theme.title,
      _Identifiers.THEME_ICON: theme.icon,
      _Identifiers.THEME_COLOR: theme.color,
      _Identifiers.THEME_ENTITLED: theme.entitled
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
class _LocalQuestionAdapter implements QuizQuestion {
  static const serializationCharacter = "##";
  static const typeTxt = "txt";
  static const typeImg = "img";
  static const typeLoc = "loc";

  String id;
  QuizTheme theme;
  Resource entitled;
  ResourceType entitledType;
  List<QuizAnswer> answers;
  int difficulty;

  _LocalQuestionAdapter({@required QuizTheme theme, @required Map<String, Object> data}) {
    this.id = data[_Identifiers.QUESTION_ID];
    this.theme = theme;

    final _entitled = data[_Identifiers.QUESTION_ENTITLED];
    final _entitledType = _strToType(data[_Identifiers.QUESTION_ENTITLED_TYPE]);
    this.entitled = Resource(resource: _entitled, type: _entitledType);

    final _answersStr = (data[_Identifiers.QUESTION_ANSWERS] as String);
    final _answers = _answersStr.split(serializationCharacter);
    final _answersType = _strToType(data[_Identifiers.QUESTION_ANSWERS_TYPE]);
    this.answers = _answers.map(
      (a) => QuizAnswer(answer: Resource(resource: a, type: _answersType))
      ).toList();
    this.answers.first.isCorrect = true;

    this.difficulty = data[_Identifiers.QUESTION_DIFFICULTY];
  }

  static Map<String, dynamic> toMap(QuizQuestion question) {
    var answers = question.answers.map((a) => a.answer.resource).join(serializationCharacter);
    var answersType = _typeToStr(question.answers.first.answer.type);
    return {
      _Identifiers.QUESTION_ID: question.id,
      _Identifiers.QUESTION_THEME: question.theme.id,
      _Identifiers.QUESTION_ENTITLED: question.entitled.resource,
      _Identifiers.QUESTION_ENTITLED_TYPE: _typeToStr(question.entitled.type),
      _Identifiers.QUESTION_ANSWERS: answers,
      _Identifiers.QUESTION_ANSWERS_TYPE: answersType,
      _Identifiers.QUESTION_DIFFICULTY: 1,
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



/// Identifiers (filename, attribute, key, etc.) used for the SQL database
class _Identifiers {
  _Identifiers._();

  static const DATABASE_NAME = "database.db";

  static const THEMES_TABLE = "themes";
  static const QUESTIONS_TABLE = "questions";

  static const THEME_ID = "id";
  static const THEME_TITLE = "title";
  static const THEME_ENTITLED = "entitled";
  static const THEME_ICON = "icon";
  static const THEME_COLOR = "color";

  static const QUESTION_ID = "id";
  static const QUESTION_THEME = "theme";
  static const QUESTION_ENTITLED = "entitled";
  static const QUESTION_ENTITLED_TYPE = "entitled_type";
  static const QUESTION_ANSWERS = "answers";
  static const QUESTION_ANSWERS_TYPE = "answers_type";
  static const QUESTION_DIFFICULTY = "difficulty";
}