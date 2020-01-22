import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:app/utils/app_logger.dart';
import 'package:app/utils/database_content_container.dart';
import 'package:flutter/widgets.dart';


class DatabaseVerificationProvider extends ChangeNotifier {

  var _logger = AppLogger();

  RemoteDatabaseRepository _remoteRepo;
  LocalDatabaseRepository _localRepo;

  bool startUpVerificationDone = false;
  bool localDatabaseUpToDate = false;
  bool unableToFetchRemoteData = true;
  bool currentLocalDatabaseExists = false;

  bool get error => !currentLocalDatabaseExists??false;
  bool get readyToStart => (startUpVerificationDone??false) && (currentLocalDatabaseExists??false);


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
      _logger.i("Current remote database version: $remoteVersion");
    } catch(e) {
      _logger.w("Unable to fetch the database remote version", e);
    }
    try {
      localVersion = await _localRepo.currentDatabaseVersion();
      _logger.i("Current local database version: $localVersion");
    } catch(e) {
      _logger.e("Unable to get the database local version", e);
    }
      
    if (remoteVersion != null && localVersion != null && remoteVersion != localVersion) {
      try {
        DatabaseContentContainer remoteDatabaseContent = await _remoteRepo.getDatabaseContent();
        await _localRepo.updateStaticDatabase(remoteVersion, remoteDatabaseContent);
        updateSuccessful = true;
        _logger.i("Local database successfully updated");
      } catch(e) {
        _logger.e("Unable to update the local database", e);
      }
    }

    this.unableToFetchRemoteData = remoteVersion == null;
    this.currentLocalDatabaseExists = localVersion != null;
    this.localDatabaseUpToDate = updateSuccessful;
    this.startUpVerificationDone = true;
    notifyListeners();

    _logger.i("Database verification process done. Here the current provider state :\n${_getStateRepresentation()}");
  }

  String _getStateRepresentation() {
    String res = "\tunableToFetchRemoteData: $unableToFetchRemoteData";
    res += "\n\tcurrentLocalDatabaseExists: $currentLocalDatabaseExists";
    res += "\n\tlocalDatabaseUpToDate: $localDatabaseUpToDate";
    res += "\n\tstartUpVerificationDone: $startUpVerificationDone";
    res += "\n\treadyToStart: $readyToStart";
    res += "\n\terror: $error";
    return res;
  }
}

