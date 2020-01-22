import 'package:app/repositories/database_content_container.dart';
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

  bool get readyToStart => startUpVerificationDone && currentLocalDatabaseExists;


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
      print("remoteVersion: $remoteVersion");
    } catch(e) {
      print(e);
    }
    try {
      localVersion = await _localRepo.currentDatabaseVersion();
      print("localVersion: $localVersion");
    } catch(e) {
      print(e);
    }
      
    if (remoteVersion != null && localVersion != null && remoteVersion != localVersion) {
      try {
        DatabaseContentContainer remoteDatabaseContent = await _remoteRepo.getDatabaseContent();
        await _localRepo.updateStaticDatabase(remoteVersion, remoteDatabaseContent);
        updateSuccessful = true;
      } catch(e) {
        print(e);
      }
    }

    this.unableToFetchRemoteData = remoteVersion == null;
    this.currentLocalDatabaseExists = localVersion != null;
    this.localDatabaseUpToDate = updateSuccessful;
    this.startUpVerificationDone = true;
    notifyListeners();
    print("""unableToFetchRemoteData: $unableToFetchRemoteData\ncurrentLocalDatabaseExists: $currentLocalDatabaseExists\nlocalDatabaseUpToDate: $localDatabaseUpToDate\nstartUpVerificationDone:$startUpVerificationDone""");
  }
}

