
import 'package:app/models/models.dart';

abstract class LocalDatabaseRepository {

  /// Get the current version of the local database
  Future<int> currentDatabaseVersion();

  /// Update the static part of the database (themes, questions)
  Future<void> updateStaticDatabase(List<QuizTheme> themes, List<QuizQuestion> questions);

}



class SQLiteLocalDatabaseRepository implements LocalDatabaseRepository {
  @override
  Future<int> currentDatabaseVersion() async {
    return null;
  }

  @override
  Future<void> updateStaticDatabase(List<QuizTheme> themes, List<QuizQuestion> questions) {
    return null;
  }

}