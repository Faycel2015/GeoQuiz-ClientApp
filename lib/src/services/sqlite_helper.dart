import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';


class SQLiteHelper {

  Future<int> getVersion() async {
    var _db = await openDatabase(LocalDatabaseIdentifiers.DATABASE_NAME);
    var v = await _db.getVersion();
    await _db.close();
    return v;
  }


  Future<Database> open({int version}) async {
    if (version == null)
      version = await getVersion();
    version = version == 0 ? 1 : version;
    var _db = await openDatabase(LocalDatabaseIdentifiers.DATABASE_NAME,
      version: version,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${LocalDatabaseIdentifiers.THEMES_TABLE} (
            ${LocalDatabaseIdentifiers.THEME_ID} text primary key,
            ${LocalDatabaseIdentifiers.THEME_TITLE} text not null,
            ${LocalDatabaseIdentifiers.THEME_ICON} text not null,
            ${LocalDatabaseIdentifiers.THEME_COLOR} int not null,
            ${LocalDatabaseIdentifiers.THEME_ENTITLED} text not null
          )
        ''');
        await db.execute('''
          CREATE TABLE ${LocalDatabaseIdentifiers.QUESTIONS_TABLE} (
            ${LocalDatabaseIdentifiers.QUESTION_ID} text primary key,
            ${LocalDatabaseIdentifiers.QUESTION_THEME} text not null,
            ${LocalDatabaseIdentifiers.QUESTION_ENTITLED} text not null,
            ${LocalDatabaseIdentifiers.QUESTION_ENTITLED_TYPE} text not null,
            ${LocalDatabaseIdentifiers.QUESTION_ANSWERS} text not null,
            ${LocalDatabaseIdentifiers.QUESTION_ANSWERS_TYPE} text not null,
            ${LocalDatabaseIdentifiers.QUESTION_DIFFICULTY} int not null
          )
        ''');
        db.execute('''
          CREATE TABLE ${LocalDatabaseIdentifiers.PROGRESSIONS_TABLE}(
            ${LocalDatabaseIdentifiers.PROGRESSION_QUESTION} text not null primary key
          )
        ''');
      }
    );
    return _db;
  }


  /// Drop the static tables (questions, themes)
  /// and recreate theme completly
  Future<void> deleteQuestions(Database db) async {
    try {
      await db.execute("DELETE FROM  ${LocalDatabaseIdentifiers.QUESTIONS_TABLE};");
    } catch (_) {}
  }

  Future<void> deleteTheme(Database db) async {
    try {
      await db.execute("DELETE FROM ${LocalDatabaseIdentifiers.THEMES_TABLE}");
    } catch (_) {}
  }
}


/// Identifiers (filename, attribute, key, etc.) used for the SQL database
class LocalDatabaseIdentifiers {
  LocalDatabaseIdentifiers._();

  static const DATABASE_NAME = "database.db";

  static const THEMES_TABLE = "themes";
  static const QUESTIONS_TABLE = "questions";
  static const PROGRESSIONS_TABLE = "local_progression";


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

  static const PROGRESSION_QUESTION = "question_id";

}