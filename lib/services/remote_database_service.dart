import 'dart:async';

import 'package:app/models/models.dart';
import 'package:app/services/remote_resource_downloader_service.dart';
import 'package:app/utils/database_content_wrapper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:logger/logger.dart';



/// Repository to manage data stored in a remote database.
abstract class IRemoteDatabaseRepository {

  /// Return the current version of the remote database
  /// 
  /// Can return null or throw an exception
  /// TODO: never returned an excpetion
  Future<int> currentDatabaseVersion();

  /// Return the entire content of the database
  /// 
  /// WARNING: this operation can be slow if the database contains a lot 
  ///          of data
  /// 
  Future<DatabaseContentWrapper> downloadDatabase();
}



/// Implementation of [IRemoteDatabaseRepository] to use Firebase platform, in
/// particular Cloud Firestore and Cloud Storage
/// This class DOES NOT handle the connexion to the platform.
/// 
/// The adapter pattern is used to adapt our remote data object to our models.
/// See https://refactoring.guru/design-patterns/adapter to know more about the
/// Adapter pattern and to have an example.
/// See [_RemoteThemeAdapter] and [_RemoteQuestionAdapter]
/// These adapters implements [QuizTheme] and [QuizQuestion] and transform use 
/// the json representation (a [Map] in reality) to build the instances.
class FirebaseRemoteDatabaseRepository implements IRemoteDatabaseRepository {

  static const timeoutDuration = Duration(seconds: 5);
  
  final Logger logger;
  final _firebaseStorage = FirebaseStorage().ref();
  final IRemoteResourcesDownloader _resourceDownloader;

  FirebaseRemoteDatabaseRepository(this.logger, {
    @required IRemoteResourcesDownloader resourceDownloader
  }) : this._resourceDownloader = resourceDownloader;

  /// Retrieve the content of the version file, and returns the version number 
  @override
  Future<int> currentDatabaseVersion() async {
    final versionFile = await _getContentFile(_Identifiers.VERSION_FILENAME);
    final version = versionFile == null ? null : int.parse(versionFile);
    logger.i("Remote version : $version");
    return version;
  }


  /// Return a [DatabaseContentWrapper] that contains all the themes and
  /// questions in the database.
  /// 
  /// Also, download the database resources
  @override
  Future<DatabaseContentWrapper> downloadDatabase() async {
    final resourcesAvailable = await _resourceDownloader.downloadResources();

    final dbContent = await _getContentFile(_Identifiers.DATABASE_FILENAME);
    final dbData = jsonDecode(dbContent);

    final themesData = dbData[_Identifiers.THEMES_KEY];
    final themes = _getThemes(data: themesData);

    final questionsData = dbData[_Identifiers.QUESTIONS_KEY];
    final questions = _getQuestions(
      data: questionsData, 
      themes: themes,
      resources: resourcesAvailable
    );

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


  /// Return a list of [_RemoteThemeAdapter] from a [Map] that contains the
  /// theme data
  List<_RemoteThemeAdapter> _getThemes({List data}) {
    final themes = List<_RemoteThemeAdapter>();
    final mapData = data.cast<Map<String, Object>>();
    for (var themeData in mapData) {
      try {
        final theme = _RemoteThemeAdapter(data: themeData);
        themes.add(theme);
      } catch (_) {}
    }
    return themes;
  }


  /// Return a list of [_RemoteQuestionAdapter] from a [Map] that contains 
  /// the question data
  List<_RemoteQuestionAdapter> _getQuestions({List data, Iterable<_RemoteThemeAdapter> themes, Map<String, String> resources}) {
    final questions = List<_RemoteQuestionAdapter>();
    final mapData = data.cast<Map<String, Object>>();
    for (var questionData in mapData) {
      try {
        final questionThemeID = questionData[_Identifiers.QUESTION_THEME_ID];
        final theme = themes.where((t) => t.id == questionThemeID).first;
        final question = _RemoteQuestionAdapter(data: questionData, theme: theme, resources: resources);
        questions.add(question);
      } catch(e) {
        logger.e("Unable to get $questionData. $e");
      }
    }
    return questions;
  }
}



/// Adapter used to adapt our remote data objects to [QuizTheme]
/// Used in [FirebaseRemoteDatabaseRepository].
class _RemoteThemeAdapter extends QuizTheme {
  _RemoteThemeAdapter({Map<String, Object> data}) {
    this.id = data[_Identifiers.THEME_ID];
    this.title = data[_Identifiers.THEME_TITLE];
    this.icon = data[_Identifiers.THEME_ICON];
    this.color = data[_Identifiers.THEME_COLOR];
    this.entitled = data[_Identifiers.THEME_ENTITLED];
  }
}



/// Adapter used to adapt our remote data objects to [QuizQuestion]
/// Used in [FirebaseRemoteDatabaseRepository].
class _RemoteQuestionAdapter implements QuizQuestion {

  String id;
  QuizTheme theme;
  Resource entitled;
  List<QuizAnswer> answers;
  int difficulty;

  _RemoteQuestionAdapter({
    Map<String, Object> data, 
    _RemoteThemeAdapter theme,
    Map<String, String> resources,
  }) {
    this.theme = theme;
    this.id = data[_Identifiers.QUESTION_ID];

    final _entitledType = _strToType(data[_Identifiers.QUESTION_ENTITLED_TYPE]);
    var _entitled = data[_Identifiers.QUESTION_ENTITLED];
    if (_entitledType == ResourceType.image)
      _entitled = resources[_entitled];
    if (_entitled == null)
      throw Exception("Resource not available on the user device");
    this.entitled = Resource(resource: _entitled, type: _entitledType);

    final _answers = (data[_Identifiers.QUESTION_ANSWERS] as List).cast<String>();
    final _answersType = _strToType(data[_Identifiers.QUESTION_ANSWERS_TYPE]);
    this.answers = _answers.map(
      (a) => QuizAnswer(answer: Resource(resource: a, type: _answersType))
    ).toList();
    this.answers.first.isCorrect = true;

    this.difficulty = data[_Identifiers.QUESTION_DIFFICULTY];
  }

  static ResourceType _strToType(String typeStr) {
    switch (typeStr) {
      case "txt" : return ResourceType.text;
      case "img" : return ResourceType.image;
      case "loc" : return ResourceType.location;
      default: throw("Not supported type ($typeStr)");
    }
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