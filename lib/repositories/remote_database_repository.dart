import 'package:app/models/models.dart';
import 'package:app/utils/database_content_container.dart';
import 'package:app/utils/database_identifiers.dart';
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

  static const VERSION_FILENAME = "version";
  static const DATABASE_FILENAME = "database.json";


  @override
  Future<int> currentDatabaseVersion() async {
    String contentFile = await  _getContentFile(VERSION_FILENAME);
    int version = int.parse(contentFile);
    return version;
  }

  @override
  Future<List<String>> downloadStorage() async {
    return null;
  }


  @override
  Future<DatabaseContentContainer> getDatabaseContent() async {
    String databaseContent = await _getContentFile(DATABASE_FILENAME);
    Map<String, Object> map = jsonDecode(databaseContent);

    List<QuizTheme> themes = List();
    for (Map<String, Object> themeData in map["themes"]) {
      try {
        var theme = QuizTheme.fromJSON(data: themeData);
        themes.add(theme);
      } catch (_) {}
    }

    List<QuizQuestion> questions = List();
    for (Map<String, Object> questionData in map["questions"]) {
      try {
        var theme = themes.where((t) => t.id == questionData[DatabaseIdentifiers.QUESTION_THEME_ID]).first;
        print("THEME" + theme.id);
        questions.add(QuizQuestion.fromJSON(data: questionData, theme: theme));
      } catch(e) {}
    }

    print("get ${themes.length} themes and ${questions.length} questions");
    return DatabaseContentContainer(themes: themes, questions: questions);
  }


  Future<String> _getContentFile(String path) async {
    final StorageReference _ref = _firebaseStorage.ref().child(path);
    String fileURL = await _ref.getDownloadURL();
    final http.Response downloadData = await http.get(fileURL);
    return utf8.decode(downloadData.bodyBytes);
  }
}





