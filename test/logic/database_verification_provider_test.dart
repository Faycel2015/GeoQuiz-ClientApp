import 'package:app/logic/database_verification_provider.dart';
import 'package:app/models/models.dart';
import 'package:app/repositories/database_content_container.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:flutter_test/flutter_test.dart';




void main() {
  
  test("Provider with errors", () {
    var provider = DatabaseVerificationProvider(
      localRepo: TestLocalDatabaseRepository(),
      remoteRepo: TestRemoteDatabaseRepository(),
    );
    
    expect(provider.unableToFetchRemoteData, true);
    expect(provider.currentLocalDatabaseExists, false);
    expect(provider.startUpVerificationDone, true);
    expect(provider.localDatabaseUpToDate, false);
  });

  test("", () {

  });
}


class TestRemoteDatabaseRepository extends RemoteDatabaseRepository {
  Future<int> currentDatabaseVersion() {
    throw UnimplementedError();
  }
  Future<List<String>> downloadStorage() {
    throw UnimplementedError();
  }
  Future<DatabaseContentContainer> getDatabaseContent() {
    throw UnimplementedError();
  }
}



class TestLocalDatabaseRepository extends LocalDatabaseRepository {
  Future<int> currentDatabaseVersion() {
    throw UnimplementedError();
  }
  Future<void> updateStaticDatabase(DatabaseContentContainer databaseContentContainer) {
    throw UnimplementedError();
  }
}


class Test2RemoteDatabaseRepository extends RemoteDatabaseRepository {
  Future<int> currentDatabaseVersion() async {
    return 10;
  }
  Future<List<String>> downloadStorage() {
    throw UnimplementedError();
  }
  Future<DatabaseContentContainer> getDatabaseContent() {
    throw UnimplementedError();
  }
}

class Test2LocalDatabaseRepository extends LocalDatabaseRepository {
  Future<int> currentDatabaseVersion() async {
    return 1;
  }
  Future<void> updateStaticDatabase(DatabaseContentContainer databaseContentContainer) {
    throw UnimplementedError();
  }
}