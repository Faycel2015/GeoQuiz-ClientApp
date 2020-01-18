import 'package:app/models/models.dart';
import 'package:app/repositories/database_content_container.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class RemoteDatabaseRepository {

  /// Return the current version of the remote database
  Future<int> currentDatabaseVersion();

  /// Return the entire content of the database (json representation)
  /// WARNING: this operation can be slow if the database contains a lot 
  ///          of data
  Future<DatabaseContentContainer> getDatabaseContent();

  /// Download a local copy of the storage stores in the remote database
  /// system. Files are downloaded inside the application directory
  /// The function returns the list of the downloaded file URIs
  Future<List<String>> downloadStorage();
}


class FirebaseRemoteDatabaseRepository implements RemoteDatabaseRepository {

  FirebaseStorage _firebaseStorage = FirebaseStorage();

  int _currentVersion;
  DatabaseContentContainer _content;


  _init() async {
    final StorageReference _ref = _firebaseStorage.ref().child("database.json");
    String fileURL = await _ref.getDownloadURL();
    final http.Response downloadData = await http.get(fileURL);
    Map<String, Object> map = jsonDecode(utf8.decode(downloadData.bodyBytes));
    _currentVersion = map["version"];
    List<QuizTheme> themes = List();
    for (Map<String, Object> themesData in map["themes"]) {
      themes.add(QuizTheme.fromJSON(data: themesData));
    }
  }

  @override
  Future<int> currentDatabaseVersion() async {
    if (_currentVersion == null)
      await _init();
    return _currentVersion;
  }

  @override
  Future<List<String>> downloadStorage() async {
    return null;
  }

  @override
  Future<DatabaseContentContainer> getDatabaseContent() async {
    if (_content == null)
      await _init();
    return _content;
  }
}





