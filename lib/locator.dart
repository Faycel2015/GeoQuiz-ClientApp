import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/local_progression_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:app/repositories/remote_resource_downloader.dart';
import 'package:app/utils/app_logger.dart';
import 'package:get_it/get_it.dart';



/// Repositories locator to retrieve repositories to used in the app
GetIt locator = GetIt.instance;



/// Register our repositories that can then be accessed anywhere with the 
/// repositories locator [locator]
/// 
/// For example, to retrieve the repository used to handle the local database:
/// ```dart
/// locator<ILocalDatabaseRepository>();
/// ```
void setupServiceLocator() {
  locator.registerLazySingleton<ILocalDatabaseRepository>(
    () => SQLiteLocalDatabaseRepository(AppLogger("SQLiteLocalDatabaseRepository"))
  );
  locator.registerLazySingleton<IRemoteResourcesDownloader>(
    () => FirebaseResourceDownloader(AppLogger("FirebaseResourceDownloader"))
  );
  locator.registerLazySingleton<IRemoteDatabaseRepository>(
    () => FirebaseRemoteDatabaseRepository(AppLogger("FirebaseRemoteDatabaseRepository"),
      resourceDownloader: locator<IRemoteResourcesDownloader>()
    )
  );
  locator.registerLazySingleton<ILocalProgressionRepository>(
    () => SQLiteLocalProgressionRepository()
  );
}