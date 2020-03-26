import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:flutter/widgets.dart';


/// Perform operations when the app starts.
/// 
/// The start up process is defined in the application documentation, please
/// see this documentation.
/// In few words, this provider check if the local database is up to date. If 
/// not the local database will be updated with the data fetched in the remote
/// database.
/// Moreover, a state is maintained to notify errors, status, etc. to listeners.
class StartUpCheckerProvider extends ChangeNotifier {

  final IRemoteDatabaseRepository _remoteRepo;
  final ILocalDatabaseRepository _localRepo;

  bool startUpVerificationDone;
  bool localDatabaseUpToDate;
  bool remoteDataFetched;
  bool localDatabaseExists;

  bool get error => !(localDatabaseExists??true);
  bool get readyToStart => (startUpVerificationDone??false) && (localDatabaseExists??false);


  StartUpCheckerProvider({
    @required IRemoteDatabaseRepository remoteRepo, 
    @required ILocalDatabaseRepository localRepo
  }) : this._remoteRepo = remoteRepo,
       this._localRepo = localRepo;


  /// See class level documentation
  performStartUpProcess() async {
    int remoteVersion = await _getRemoteDbVersion();
    int localVersion = await _getLocalDbVersion();

    if (remoteVersion != null && (localVersion == null || localVersion != remoteVersion)) {
      bool updateResult = await _updateLocalDatabase(version: remoteVersion);
      localVersion = updateResult ? remoteVersion : null;
    }

    this.remoteDataFetched = (remoteVersion == null);
    this.localDatabaseExists = (localVersion != null);
    this.localDatabaseUpToDate = (localVersion == remoteVersion);
    this.startUpVerificationDone = true;
    notifyListeners();
  }

  // performStartUpProcess() async {
  //   this.remoteDataFethed = true;
  //   this.localDatabaseExists = true;
  //   this.localDatabaseUpToDate = true;
  //   this.startUpVerificationDone = true;
  //   notifyListeners();
  // }


  /// returns the remote database version
  /// returns null if an error occured
  Future<int> _getRemoteDbVersion() async {
    int remoteVersion;
    try {
      remoteVersion = await _remoteRepo.currentDatabaseVersion();
    } catch(e) { }
    return remoteVersion;
  }


  /// returns the local database version
  /// returns null if an error occured
  Future<int> _getLocalDbVersion() async {
    int localVersion;
    try {
      localVersion = await _localRepo.currentDatabaseVersion();
    } catch(e) { }
    return localVersion;
  }


  /// update the local database to a new [version]
  Future<bool> _updateLocalDatabase({@required int version}) async {
    try {
      var remoteDatabaseContent = await _remoteRepo.downloadDatabase();
      await _localRepo.updateStaticDatabase(version, remoteDatabaseContent);
      return true;
    } catch(e) {
      return false;
    }
  }
}

