import 'dart:async';

import 'package:app/models/models.dart';
import 'package:app/utils/database_content_container.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



/// Repository to manage data stored in a remote database.
abstract class RemoteDatabaseRepository {

  /// Return the current version of the remote database
  /// Can return null or throw an exception
  Future<int> currentDatabaseVersion();

  /// Return the entire content of the database
  /// WARNING: this operation can be slow if the database contains a lot 
  ///          of data
  Future<DatabaseContentWrapper> getDatabaseContent();
}



/// Implementation of [RemoteDatabaseRepository] to use Firebase platform, in
/// particular Cloud Firestore and Cloud Storage
/// This class DOES NOT handle the connexion to the platform.
/// 
/// The adapter pattern is used to adapt our remote data object to our models.
/// See https://refactoring.guru/design-patterns/adapter to know more about the
/// Adapter pattern and to have an example.
/// See [RemoteQuizThemeAdapter] and [RemoteQuizQuestionAdapter]
/// These adapters implements [QuizTheme] and [QuizQuestion] and transform use 
/// the json representation (a [Map] in reality) to build the instances.
class FirebaseRemoteDatabaseRepository implements RemoteDatabaseRepository {

  static const timeoutDuration = Duration(seconds: 5);
  final _firebaseStorage = FirebaseStorage().ref();


  /// Retrieve the content of the version file, and returns the version number 
  @override
  Future<int> currentDatabaseVersion() async {
    final versionFile = await _getContentFile(_Identifiers.VERSION_FILENAME);
    final version = versionFile == null ? null : int.parse(versionFile);
    return version;
  }


  /// Return a [DatabaseContentWrapper] that contains all the themes and
  /// questions in the database.
  @override
  Future<DatabaseContentWrapper> getDatabaseContent() async {
    final dbContent = await _getContentFile(_Identifiers.DATABASE_FILENAME);
    final dbData = jsonDecode(dbContent);

    final themesData = dbData[_Identifiers.THEMES_KEY];
    final themes = _getThemes(data: themesData);

    final questionsData = dbData[_Identifiers.QUESTIONS_KEY];
    final questions = _getQuestions(data: questionsData, themes: themes);

    return DatabaseContentWrapper(themes: themes, questions: questions);
  }


  /// Retrieve the content of a file from it's [filename]
  /// 
  Future<String> _getContentFile(String filename) async {
    StreamSubscription getDownloadURLStreamSub;
    StreamSubscription getDataStreamSub;

    final completer = Completer<String>();
    final _ref = _firebaseStorage.child(filename);

    getDownloadURLStreamSub = _ref.getDownloadURL().asStream().listen((url) async {
      getDataStreamSub = http.get(url).asStream().listen((downloadData) async {
      final res = downloadData.statusCode == 200 ? downloadData.body : null;
      if (!completer.isCompleted)
        completer.complete(res);
      });
    });

    await Future.delayed(timeoutDuration, () {
      if (!completer.isCompleted)
          completer.complete(null);
    });

    getDownloadURLStreamSub.cancel();
    getDataStreamSub.cancel();

    return completer.future;
  }


  /// Return a list of [RemoteQuizThemeAdapter] from a [Map] that contains the
  /// theme data
  List<RemoteQuizThemeAdapter> _getThemes({List data}) {
    final themes = List<RemoteQuizThemeAdapter>();
    final mapData = data.cast<Map<String, Object>>();
    for (var themeData in mapData) {
      try {
        final theme = RemoteQuizThemeAdapter(data: themeData);
        themes.add(theme);
      } catch (_) {}
    }
    return themes;
  }


  /// Return a list of [RemoteQuizQuestionAdapter] from a [Map] that contains 
  /// the question data
  List<RemoteQuizQuestionAdapter> _getQuestions({List data, Iterable<RemoteQuizThemeAdapter> themes}) {
    final questions = List<RemoteQuizQuestionAdapter>();
    final mapData = data.cast<Map<String, Object>>();
    for (var questionData in mapData) {
      try {
        final questionThemeID = questionData[_Identifiers.QUESTION_THEME_ID];
        final theme = themes.where((t) => t.id == questionThemeID).first;
        final question = RemoteQuizQuestionAdapter(data: questionData, theme: theme);
        questions.add(question);
      } catch(e) {}
    }
    return questions;
  }
}



/// Adapter used to adapt our remote data objects to [QuizTheme]
/// Used in [FirebaseRemoteDatabaseRepository].
class RemoteQuizThemeAdapter implements QuizTheme {
  String id;
  String title;
  String icon;
  int color;
  String entitled;

  RemoteQuizThemeAdapter({Map<String, Object> data}) {
    this.id = data[_Identifiers.THEME_ID];
    this.title = data[_Identifiers.THEME_TITLE];
    this.icon = data[_Identifiers.THEME_ICON];
    this.color = data[_Identifiers.THEME_COLOR];
    this.entitled = data[_Identifiers.THEME_ENTITLED];
  }
}



/// Adapter used to adapt our remote data objects to [QuizQuestion]
/// Used in [FirebaseRemoteDatabaseRepository].
class RemoteQuizQuestionAdapter implements QuizQuestion {
  String id;
  QuizTheme theme;
  String entitled;
  ResourceType entitledType;
  List<String> answers;
  ResourceType answersType;
  int difficulty;

  RemoteQuizQuestionAdapter({Map<String, Object> data, RemoteQuizThemeAdapter theme}) {
    this.theme = theme;
    this.id = data[_Identifiers.QUESTION_ID];
    this.entitled = data[_Identifiers.QUESTION_ENTITLED];
    this.entitledType = data[_Identifiers.QUESTION_ENTITLED_TYPE];
    this.answers = data[_Identifiers.QUESTION_ANSWERS];
    this.answersType = data[_Identifiers.QUESTION_ENTITLED_TYPE];
    this.difficulty = data[_Identifiers.QUESTION_DIFFICULTY];
  }
}



/// Identifiers (filename, attribute, key, etc.) used in the firebase platform
class _Identifiers {
  _Identifiers._();

  static const DATABASE_FILENAME = "database.json";
  static const VERSION_FILENAME = "version";

  static const THEMES_KEY = "themes";
  static const QUESTIONS_KEY = "questions";

  static const THEME_ID = "id";
  static const THEME_TITLE = "title";
  static const THEME_ICON = "icon";
  static const THEME_COLOR = "color";
  static const THEME_ENTITLED = "entitled";

  static const QUESTION_ID = "id";
  static const QUESTION_THEME_ID = "theme";
  static const QUESTION_ENTITLED = "entitled";
  static const QUESTION_ANSWERS = "answers";
  static const QUESTION_ANSWERS_TYPE = "answers_type";
  static const QUESTION_ENTITLED_TYPE = "entitled_type";
  static const QUESTION_DIFFICULTY = "difficulty";
}