import 'package:app/models/models.dart';
import 'package:app/models/progression.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:app/ui/shared/values.dart';
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
  
  ///
  ///
  ///
  @override
  Future addQuestions(List<QuizQuestion> questions) async {
    var db = await open();
    var batch = db.batch();
    for (var question in questions) {
      batch.insert(_Identifiers.PROGRESSIONS_TABLE, {
        _Identifiers.PROGRESSION_QUESTION: question.id
      });
    }
    await batch.commit(continueOnError: true);
  }


  ///
  ///
  ///
  @override
  Future<Map<QuizTheme, QuizThemeProgression>> retrieveProgressions(List<QuizTheme> themes) async {
    var db = await open();

    var progress = Map<QuizTheme, QuizThemeProgression>();
    for (var theme in themes) {
      var queryRes = await db.rawQuery('''
        SELECT COUNT() 
        FROM ${LocalDatabaseIdentifiers.QUESTIONS_TABLE} A
        WHERE A.${LocalDatabaseIdentifiers.QUESTION_THEME} = ${theme.id}
        INNER JOIN ${LocalDatabaseIdentifiers.QUESTIONS_TABLE} B
        ON A.${_Identifiers.PROGRESSION_QUESTION} = B.${LocalDatabaseIdentifiers.QUESTION_ID}
      ''');
      print("");
      // progress[theme] = queryRes.first;
    }
    return progress;
  }


  Future<Database> open() async {
    return await openDatabase(_Identifiers.DATABASE_NAME, onCreate: (db, v) {
      db.execute('''
        CREATE TABLE ${_Identifiers.PROGRESSIONS_TABLE}(
          ${_Identifiers.PROGRESSION_QUESTION} text not null
        )
        ''');
    });
  }
}


class _Identifiers {
  _Identifiers._();

  static const DATABASE_NAME = Values.sqlLiteDatabaseName;
  static const PROGRESSIONS_TABLE = "local_progression";

  static const PROGRESSION_QUESTION = "question_id";
}