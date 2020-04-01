import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:flutter/widgets.dart';

/// The current status of the [StartUpProvider]
enum StartUpStatus {
  /// Startup process not launched, call [StartUpProvider.init] to launched it.
  idle,

  /// Startup process launched and still in progress. It is not yet finished
  /// but it started, it probably fetch remote data or update the local
  /// database.
  busy,

  /// Startup process finished without errors. It doesn't mean that the local
  /// database version is up-to-date, but it means that a version of the
  /// local database exists (and maybe up-to-date)
  loaded,

  /// Startup process finished but an error occured. An error is defined by the
  /// following assertion :
  ///   -> no local database version exists at the end of the startup process
  error,
}

/// Check if the local database is up-to-date, try to update it if not.
/// 
/// The logic process is defined in the [StartUpProvider.init] method. Its job
/// is to retrieve the remote database version, compare it with the local 
/// database version AND is the both versions doesn't match, fetch the remote
/// data to update the local database.
/// 
/// The current provider [status] gives information about the step in this 
/// process. See [StartUpStatus] to know exactly the meaning of each status.
/// 
/// {@tool sample}
/// Use it to update what is displayed based on the [status] property
/// 
/// ```dart
/// ProviderNotifier<StartUpProvider>(
///   builder: (context, provider, child) {
///     switch (provider.status) {
///       ... // handle different cases
///     }
///   }
/// )
/// ```
/// {@end-tool}
///
/// The provider is declared in the [Locator] class, the service locator used
/// to retrieve service and provider instances. When the instance is created,
/// the [StartUpProvider.init] method is also called.
/// So normally you don't have to handle the provider creation, neither the
/// initialization process.
/// However, you can call again the init method to reinit the provider state to
/// try to re-update the local database.
class StartUpProvider extends ChangeNotifier {
  /// Create the provider with necessary services, doesn't launch any process
  StartUpProvider({
    @required IRemoteDatabaseRepository remoteRepo, 
    @required ILocalDatabaseRepository localRepo
  }) : this._remoteRepo = remoteRepo,
       this._localRepo = localRepo;

  /// Service used to fetch questions and themes.
  final IRemoteDatabaseRepository _remoteRepo;

  /// Service used to update the local database.
  final ILocalDatabaseRepository _localRepo;

  /// See [status] getter and setter. It is private because when the status
  /// changed, it will notify listeners.
  StartUpStatus _status = StartUpStatus.idle;

  /// Returns true if the application is ready to start, meaning that a local
  /// database exists with questions and themes.
  bool get isReady => status == StartUpStatus.loaded;

  /// Status of the provider, will notify clients when the value changed
  /// The [ProviderNotifier] widget can be used to listen the status state.
  StartUpStatus get status => _status;

  /// Setter of the status property to notify clients when the status changed
  set status(StartUpStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
  
  /// Retrieve the remote database version, compare it with the local 
  /// database version AND is the both versions doesn't match, fetch the remote
  /// data to update the local database.
  /// 
  /// This method update the [status] depending on the process avancement. The
  /// changement of the [status] property will notify clients that a changement
  /// occured.
  init() async {
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

