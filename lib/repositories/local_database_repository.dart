
import 'package:app/models/models.dart';

abstract class LocalDatabaseRepository {

  /// Get the current version of the local database
  Future<int> getDatabaseVersion();

  /// Update the static part of the database (themes, questions)
  Future<void> updateStaticDatabase(List<QuizTheme> themes, List<QuizQuestion> questions);

}



class SQLiteLocalDatabaseRepository implements LocalDatabaseRepository {
  @override
  Future<int> getDatabaseVersion() {
    return null;
  }

  @override
  Future<void> updateStaticDatabase(List<QuizTheme> themes, List<QuizQuestion> questions) {
    return null;
  }

}