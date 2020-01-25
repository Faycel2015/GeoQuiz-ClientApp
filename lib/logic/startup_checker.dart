import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:app/utils/app_logger.dart';
import 'package:flutter/widgets.dart';


/// Perform operations when the app starts.
/// The start up process is defined in the application documentation, please
/// see this documentation.
/// In few words, this provider check if the local database is up to date. If 
/// not the local database will be updated with the data fetched in the remote
/// database.
/// Moreover, a state is maintained to notify errors, status, etc. to listeners.
class StartUpCheckerProvider extends ChangeNotifier {

  final _logger = AppLogger();

  final RemoteDatabaseRepository _remoteRepo;
  final LocalDatabaseRepository _localRepo;

  bool startUpVerificationDone;
  bool localDatabaseUpToDate;
  bool remoteDataFethed;
  bool localDatabaseExists;

  bool get error => !(localDatabaseExists??true);
  bool get readyToStart => (startUpVerificationDone??false) && (localDatabaseExists??false);


  StartUpCheckerProvider({
    @required RemoteDatabaseRepository remoteRepo, 
    @required LocalDatabaseRepository localRepo
  }) : this._remoteRepo = remoteRepo,
       this._localRepo = localRepo;


  /// See class level documentation
  performStartUpProcess() async {
    int remoteVersion = await _getRemoteDbVersion();
    int localVersion = await _getLocalDbVersion();

    if (remoteVersion != null && (localVersion == null || localVersion != remoteVersion)) {
      if (await _updateLocalDatabase(version: remoteVersion))
        localVersion = remoteVersion;
    }

    this.remoteDataFethed = remoteVersion == null;
    this.localDatabaseExists = localVersion != null;
    this.localDatabaseUpToDate = localVersion == remoteVersion;
    this.startUpVerificationDone = true;
    notifyListeners();
    _logState();
  }


  /// returns the remote database version
  /// returns null if an error occured
  Future<int> _getRemoteDbVersion() async {
    int remoteVersion;
    try {
      remoteVersion = await _remoteRepo.currentDatabaseVersion();
      _logger.i("Current remote database version: $remoteVersion");
    } catch(e) {
      _logger.w("Unable to fetch the database remote version", e);
    }
    return remoteVersion;
  }


  /// returns the local database version
  /// returns null if an error occured
  Future<int> _getLocalDbVersion() async {
    int localVersion;
    try {
      localVersion = await _localRepo.currentDatabaseVersion();
      _logger.i("Current local database version: $localVersion");
    } catch(e) {
      _logger.e("Unable to get the database local version", e);
    }
    return localVersion;
  }


  /// update the local database to a new [version]
  Future<bool> _updateLocalDatabase({@required int version}) async {
    try {
      var remoteDatabaseContent = await _remoteRepo.getDatabaseContent();
      _logger.i("${remoteDatabaseContent.themes.length} themes");
      _logger.i("${remoteDatabaseContent.questions.length} questions");
      await _localRepo.updateStaticDatabase(version, remoteDatabaseContent);
      _logger.i("Local database successfully updated");
      return true;
    } catch(e) {
      _logger.e("Unable to update the local database", e);
      return false;
    }
  }


  /// Just a method to log the current state 
  _logState() {
    var state = "\tstartUpVerificationDone: $startUpVerificationDone";
    state += "\n\tunableToFetchRemoteData: $remoteDataFethed";
    state += "\n\tcurrentLocalDatabaseExists: $localDatabaseExists";
    state += "\n\tlocalDatabaseUpToDate: $localDatabaseUpToDate";
    state += "\n\treadyToStart: $readyToStart";
    state += "\n\terror: $error";
    _logger.i("Start up process done : \n" + state);
  }
}

