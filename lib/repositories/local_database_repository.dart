
import 'package:app/models/models.dart';
import 'package:app/utils/database_content_container.dart';
import 'package:app/utils/database_identifiers.dart';
import 'package:sqflite/sqflite.dart';


abstract class LocalDatabaseRepository {

  /// Get the current version of the local database
  Future<int> currentDatabaseVersion();

  /// Update the static part of the database (themes, questions)
  Future<void> updateStaticDatabase(int version, DatabaseContentContainer databaseContentContainer);

}



class SQLiteLocalDatabaseRepository implements LocalDatabaseRepository {

  static const DBNAME = "database.db";

  @override
  Future<int> currentDatabaseVersion() async {
    var _db = await openDatabase(DBNAME);
    int v = await _db.getVersion();
    await _db.close();
    return v;
  }

  @override
  Future<void> updateStaticDatabase(int version, DatabaseContentContainer databaseContentContainer) async {
    await deleteDatabase(DBNAME);

    var db = await openDatabase(
      DBNAME,
      version: version,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE ${DatabaseIdentifiers.THEMES_TABLE} (
            ${DatabaseIdentifiers.THEME_ID} text primary key,
            ${DatabaseIdentifiers.THEME_TITLE} text not null,
            ${DatabaseIdentifiers.THEME_ICON} text not null,
            ${DatabaseIdentifiers.THEME_COLOR} int not null,
            ${DatabaseIdentifiers.THEME_ENTITLED} text not null
          )
        ''');
        await db.execute('''
          CREATE TABLE ${DatabaseIdentifiers.QUESTIONS_TABLE} (
            ${DatabaseIdentifiers.QUESTION_ID} text primary key,
            ${DatabaseIdentifiers.QUESTION_ENTITLED} text not null,
            ${DatabaseIdentifiers.QUESTION_ENTITLED_TYPE} text not null,
            ${DatabaseIdentifiers.QUESTION_ANSWERS} text not null,
            ${DatabaseIdentifiers.QUESTION_ANSWERS_TYPE} text not null,
            ${DatabaseIdentifiers.QUESTION_DIFFICULTY} int not null
          )
        ''');
      }
    );
    
    Batch batch = db.batch();
    for (QuizTheme t in databaseContentContainer.themes??[]) {
      batch.insert(DatabaseIdentifiers.THEMES_TABLE, t.toMap());
    }
    for (QuizQuestion q in databaseContentContainer.questions??[]) {
      batch.insert(DatabaseIdentifiers.QUESTIONS_TABLE, q.toMap());
    }
    try {
      print(await batch.commit(continueOnError: true));
    } catch(e) {}
    await db.close();
  }

  Future<List<QuizTheme>> getThemes() async {
    var db = await openDatabase(DBNAME);
    List<QuizTheme> themes = List();
    List<Map<String, Object>> themesData = await db.query(DatabaseIdentifiers.THEMES_TABLE);
    for (var t in themesData) {
      themes.add(QuizTheme.fromJSON(data: t));
    }
    await db.close();
    return themes;
  }

}