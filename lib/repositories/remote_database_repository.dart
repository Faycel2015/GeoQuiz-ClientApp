

abstract class RemoteDatabaseRepository {

  /// Return the current version of the remote database
  Future<int> currentDatabaseVersion();

  /// Return the entire content of the database (json representation)
  /// WARNING: this operation can be slow if the database contains a lot 
  ///          of data
  Future<String> getDatabaseContentJson();

  /// Download a local copy of the storage stores in the remote database
  /// system. Files are downloaded inside the application directory
  /// The function returns the list of the downloaded file URIs
  Future<List<String>> downloadStorage();
}


class FirebaseRemoteDatabaseDownloader implements RemoteDatabaseRepository {

  @override
  Future<int> currentDatabaseVersion() async {
    return null;
  }

  @override
  Future<List<String>> downloadStorage() async {
    return null;
  }

  @override
  Future<String> getDatabaseContentJson() async {
    return null;
  }
}