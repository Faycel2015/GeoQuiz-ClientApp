import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:flutter/widgets.dart';

class DatabaseVerificationProvider extends ChangeNotifier {

  RemoteDatabaseRepository remoteRepo = FirebaseRemoteDatabaseRepository();
  LocalDatabaseRepository localRepo = SQLiteLocalDatabaseRepository();

  

}