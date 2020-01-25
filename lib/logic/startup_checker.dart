import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:app/utils/app_logger.dart';
import 'package:app/utils/database_content_container.dart';
import 'package:flutter/widgets.dart';


class StartUpCheckerProvider extends ChangeNotifier {

  var _logger = AppLogger();

  RemoteDatabaseRepository _remoteRepo;
  LocalDatabaseRepository _localRepo;

  bool startUpVerificationDone;
  bool localDatabaseUpToDate;
  bool remoteDataFethed;
  bool localDatabaseExists;

  bool get error => !(localDatabaseExists??true);
  bool get readyToStart => (startUpVerificationDone??false) && (localDatabaseExists??false);


  StartUpCheckerProvider({@required RemoteDatabaseRepository remoteRepo, @required LocalDatabaseRepository localRepo})
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



    if (remoteVersion != null && (localVersion == null || localVersion != remoteVersion)) {
      try {
        DatabaseContentWrapper remoteDatabaseContent = await _remoteRepo.getDatabaseContent();
        await _localRepo.updateStaticDatabase(remoteVersion, remoteDatabaseContent);
        localVersion = remoteVersion;
        _logger.i("Local database successfully updated");
      } catch(e) {
        _logger.e("Unable to update the local database", e);
      }
    }

    this.remoteDataFethed = remoteVersion == null;
    this.localDatabaseExists = localVersion != null;
    this.localDatabaseUpToDate = localVersion == remoteVersion;
    this.startUpVerificationDone = true;
    notifyListeners();

    _logger.i("Database verification process done. Here the current provider state :\n${_getStateRepresentation()}");
  }


  /// 
  String _getStateRepresentation() {
    String res = "\tstartUpVerificationDone: $startUpVerificationDone";
    res += "\n\tunableToFetchRemoteData: $remoteDataFethed";
    res += "\n\tcurrentLocalDatabaseExists: $localDatabaseExists";
    res += "\n\tlocalDatabaseUpToDate: $localDatabaseUpToDate";
    res += "\n\treadyToStart: $readyToStart";
    res += "\n\terror: $error";
    return res;
  }
}

