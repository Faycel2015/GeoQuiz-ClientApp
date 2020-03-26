import 'package:app/models/models.dart';
import 'package:app/models/progression.dart';
import 'package:app/repositories/sqlite_helper.dart';
import 'package:sqflite/sqflite.dart';


/// Service used to handle to local progression of [QuizTheme]
/// 
/// The local progression is associated with a theme. It's the percentage of the
/// discovery of the theme (the amount of questions answers correctly). The 
/// local progressions are updated at the end of each party.
///
/// It allows to :
/// - retrieve the local progression thanks to [retrieveProgressions()]
/// - add new questions to the local progression thanks to [addQuestions()]
/// 
/// See :
/// - [SQLiteLocalProgressionRepository] implementation that used SQLite
abstract class ILocalProgressionRepository {

  ///
  ///
  ///
  Future addQuestions(List<QuizQuestion> questions);

  ///
  ///
  ///
  Future<Map<QuizTheme, QuizThemeProgression>> retrieveProgressions(List<QuizTheme> themes);
}



///
///
/// Table fields :
/// - `question_id` :
class SQLiteLocalProgressionRepository implements ILocalProgressionRepository {

  final int version = 1;

  final SQLiteHelper database = SQLiteHelper();
  
  ///
  ///
  ///
  @override
  Future addQuestions(List<QuizQuestion> questions) async {
    var db = await database.open();
    var batch = db.batch();
    for (var question in questions) {
      batch.insert(LocalDatabaseIdentifiers.PROGRESSIONS_TABLE, {
        LocalDatabaseIdentifiers.PROGRESSION_QUESTION: question.id
      });
    }
    await batch.commit(continueOnError: true);
  }


  ///
  ///
  ///
  @override
  Future<Map<QuizTheme, QuizThemeProgression>> retrieveProgressions(List<QuizTheme> themes) async {
    var db = await database.open();

    var progress = Map<QuizTheme, QuizThemeProgression>();
    for (var theme in themes) {
      var countQuestion = await db.rawQuery('''
        SELECT COUNT() 
        FROM ${LocalDatabaseIdentifiers.QUESTIONS_TABLE} A
        WHERE A.${LocalDatabaseIdentifiers.QUESTION_THEME} = '${theme.id}'
      ''');
      var countAnsweredQuestions = await db.rawQuery('''
        SELECT COUNT() 
        FROM ${LocalDatabaseIdentifiers.QUESTIONS_TABLE} A
        INNER JOIN ${LocalDatabaseIdentifiers.PROGRESSIONS_TABLE} B
        ON A.${LocalDatabaseIdentifiers.QUESTION_ID} = B.${LocalDatabaseIdentifiers.PROGRESSION_QUESTION}
        WHERE A.${LocalDatabaseIdentifiers.QUESTION_THEME} = '${theme.id}'
      ''');

      int countTotal = Sqflite.firstIntValue(countQuestion);
      int countAnswered = Sqflite.firstIntValue(countAnsweredQuestions);
      int percentage = countTotal == 0 ? 0 : ((countAnswered / countTotal) * 100).round();
      progress[theme] = QuizThemeProgression(
        theme: theme, 
        percentage: percentage
      );
    }
    return progress;
  }
}