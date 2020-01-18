import 'package:app/models/models.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:flutter/widgets.dart';

class DatabaseVerificationProvider extends ChangeNotifier {

  RemoteDatabaseRepository _remoteRepo;
  LocalDatabaseRepository _localRepo;

  bool startUpVerificationDone = false;
  bool localDatabaseUpToDate = false;
  bool unableToFetchRemoteData = true;
  bool currentLocalDatabaseExists = false;

  bool get readyToStart => startUpVerificationDone && localDatabaseUpToDate && currentLocalDatabaseExists;


  DatabaseVerificationProvider({@required RemoteDatabaseRepository remoteRepo, @required LocalDatabaseRepository localRepo})
  : assert(remoteRepo != null),
    assert(localRepo != null)
  {
    _remoteRepo = remoteRepo;
    _localRepo = localRepo;
    performStartUpProcess();
  }


  performStartUpProcess() async {
    int remoteVersion;
    int localVersion;
    bool updateSuccessful = false;

    try {
      remoteVersion = await _remoteRepo.currentDatabaseVersion();
    } catch(e) {
    }
    try {
      localVersion = await _localRepo.currentDatabaseVersion();
    } catch(e) {
    }
      
    if (remoteVersion != null && localVersion != null && remoteVersion != localVersion) {
      String remoteDatabaseContent = await _remoteRepo.getDatabaseContentJson();
      _ModelsTuple models = _getModelsFromJSON(remoteDatabaseContent);
      try {
        await _localRepo.updateStaticDatabase(models?.themes, models?.questions);
        updateSuccessful = true;
      } catch(e) {
      }
    }


    this.unableToFetchRemoteData = remoteVersion == null;
    this.currentLocalDatabaseExists = localVersion != null;
    this.localDatabaseUpToDate = updateSuccessful;
    this.startUpVerificationDone = true;
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
