import 'package:app/models/models.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:flutter/widgets.dart';

class DatabaseVerificationProvider extends ChangeNotifier {

  RemoteDatabaseRepository _remoteRepo = FirebaseRemoteDatabaseRepository();
  LocalDatabaseRepository _localRepo = SQLiteLocalDatabaseRepository();

  bool startUpVerificationDone = false;
  bool localDatabaseUpToDate = false;
  bool unableToFetchRemoteData = true;
  bool currentLocalDatabaseExists = false;

  bool get readyToStart => startUpVerificationDone && localDatabaseUpToDate && currentLocalDatabaseExists;


  DatabaseVerificationProvider() {
    _performStartUpProcess();
  }


  _performStartUpProcess() async {
    bool remoteDataFetched = true;
    bool localDataFetched = true;

    int remoteVersion = await _remoteRepo.currentDatabaseVersion()
      .catchError((e) => remoteDataFetched = false);
    int localVersion = await _localRepo.currentDatabaseVersion()
      .catchError((e) => localDataFetched = true);

    if (remoteVersion != localVersion) {
      String remoteDatabaseContent = await _remoteRepo.getDatabaseContentJson();
      _ModelsTuple models = _getModelsFromJSON(remoteDatabaseContent);
      _localRepo.updateStaticDatabase(models?.themes, models?.questions);
    }

    this.unableToFetchRemoteData = !remoteDataFetched;
    this.currentLocalDatabaseExists = localDataFetched;
    this.localDatabaseUpToDate = true;
    notifyListeners();
  }

  _ModelsTuple _getModelsFromJSON(String json) {
    return _ModelsTuple();
  }
}


class _ModelsTuple {
  List<QuizQuestion> questions;
  List<QuizTheme> themes;
  
  _ModelsTuple({this.questions, this.themes});
}
