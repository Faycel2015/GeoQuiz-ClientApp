import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:flutter/widgets.dart';

///
///
enum StartUpStatus {
  ///
  idle,

  ///
  busy,

  ///
  loaded,

  ///
  error,
}


/// Perform operations when the app starts.
/// 
/// The start up process is defined in the application documentation, please
/// see this documentation.
/// In few words, this provider check if the local database is up to date. If 
/// not the local database will be updated with the data fetched in the remote
/// database.
/// Moreover, a state is maintained to notify errors, status, etc. to listeners.
class StartUpProvider extends ChangeNotifier {

  StartUpProvider({
    @required IRemoteDatabaseRepository remoteRepo, 
    @required ILocalDatabaseRepository localRepo
  }) : this._remoteRepo = remoteRepo,
       this._localRepo = localRepo;

  final IRemoteDatabaseRepository _remoteRepo;

  final ILocalDatabaseRepository _localRepo;

  StartUpStatus _status = StartUpStatus.idle;

  bool get isReady => status == StartUpStatus.loaded;

  StartUpStatus get status => _status;

  set status(StartUpStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
  /// See class level documentation
  performStartUpProcess() async {
    status = StartUpStatus.busy;

    int remoteVersion = await _remoteRepo.currentDatabaseVersion();
    int localVersion = await _localRepo.currentDatabaseVersion();

    bool needToBeUpdated = remoteVersion != null 
        && (localVersion == null || localVersion != remoteVersion);
    if (needToBeUpdated) {
      bool result = await _updateLocalDatabase(version: remoteVersion);
      localVersion = result == true ? remoteVersion : null;
    }

    status = localVersion == null ? StartUpStatus.error : StartUpStatus.loaded;
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

