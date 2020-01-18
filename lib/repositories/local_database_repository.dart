
import 'package:app/models/models.dart';
import 'package:app/repositories/database_content_container.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:sqflite/sqflite.dart';

abstract class LocalDatabaseRepository {

  /// Get the current version of the local database
  Future<int> currentDatabaseVersion();

  /// Update the static part of the database (themes, questions)
  Future<void> updateStaticDatabase(DatabaseContentContainer databaseContentContainer);

}



class SQLiteLocalDatabaseRepository implements LocalDatabaseRepository {

  static const DBNAME = "database.db";
  static const THEMES_TABLE = "Themes";
  static const QUESTIONS_TABLE = "Questions";
  static const LOCALPROGRESSION_TABLE = "LocalProgression";

  Database _db;


  open() async {
    _db = await openDatabase(DBNAME, version: 1,
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE $THEMES_TABLE(id TEXT, title TEXT, icon TEXT, color INTEGER, entitled TEXT)");
        await db.execute("CREATE TABLE $QUESTIONS_TABLE(id TEXT, entitled TEXT, entitledType TEXT, answers TEXT, answersType TEXT, difficulty INTEGER)");
        await db.execute("CREATE TABLE $LOCALPROGRESSION_TABLE(themeId TEXT, questionAnswered INTEGER)");
      }
    );
  }

  close() async {
    await _db.close();
  }
  
  @override
  Future<int> currentDatabaseVersion() async {
    await open();
    int v = await _db.getVersion();
    close();
    return v;
  }

  @override
  Future<void> updateStaticDatabase(DatabaseContentContainer databaseContentContainer) async {
    await open();
    for (QuizTheme t in databaseContentContainer.themes) {
      _db.insert(THEMES_TABLE, t.toMap());
    }
    for (QuizQuestion q in databaseContentContainer.questions) {
      _db.insert(QUESTIONS_TABLE, q.toMap());
    }
    await close();
    return null;
  }

}