
import 'package:app/models/models.dart';
import 'package:sqflite/sqflite.dart';

abstract class LocalDatabaseRepository {

  /// Get the current version of the local database
  Future<int> currentDatabaseVersion();

  /// Update the static part of the database (themes, questions)
  Future<void> updateStaticDatabase(List<QuizTheme> themes, List<QuizQuestion> questions);

}



class SQLiteLocalDatabaseRepository implements LocalDatabaseRepository {

  static const DBNAME = "database.db";
  Database _db;

  open() async {
    _db = await openDatabase(DBNAME, version: 1,
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE Themes(id TEXT, title TEXT, icon TEXT, color INTEGER, entitled TEXT)");
        await db.execute("CREATE TABLE Questions(id TEXT, entitled TEXT, entitledType TEXT, answers TEXT, answersType TEXT, difficulty INTEGER)");
        await db.execute("CREATE TABLE LocalProgression(themeId TEXT, questionAnswered INTEGER)");
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
  Future<void> updateStaticDatabase(List<QuizTheme> themes, List<QuizQuestion> questions) {
    return null;
  }

}