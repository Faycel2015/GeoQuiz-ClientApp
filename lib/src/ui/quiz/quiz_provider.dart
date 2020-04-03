import 'dart:async';

import 'package:app/src/models/models.dart';
import 'package:app/src/services/local_database_service.dart';
import 'package:flutter/widgets.dart';

///
class QuizConfig {

  Set<QuizTheme> themes;
  DifficultyConfig difficultyData;

  QuizConfig({this.themes, this.difficultyData});
}

/// 0 < difficulty < 100
class DifficultyConfig {
  static int max = 100;
  static int min = 0;
  bool _automatic = true;
  bool get automatic => _automatic??true;
  set automatic(b) => _automatic = b;
  int _difficultyChose;
  int get difficultyChose => _difficultyChose??0;
  set difficultyChose(v) => _difficultyChose = v;
  DifficultyConfig({
    bool automatic, 
    int difficultyChose
  }) : _automatic = automatic,
       _difficultyChose = difficultyChose;
}

///
enum QuizState {
  /// nothin happened
  idle,

  /// loading questions
  busy,

  /// party in progress
  inProgress,

  /// party finished
  finished,

  /// an error occured to fetch questions
  error
}


class QuizProvider extends ChangeNotifier {

  QuizProvider({
    @required ILocalDatabaseRepository localDbService,
    @required this.config
  }) : _localRepo = localDbService;

  final ILocalDatabaseRepository _localRepo;

  final QuizConfig config;

  QuizState _state = QuizState.idle;

  QuizState get state => _state;

  set state(state) {
    _state = state;
    notifyListeners();
  }

  Iterator<QuizQuestion> _questionsIterator;

  List<QuizQuestion> correctlyAnsweredQuestion = [];

  QuizQuestion get currentQuestion => _questionsIterator?.current;

  int totalQuestionNumber = 0;
  
  int currentQuestionNumber = 0; 

  ///
  Future prepareGame() async {
    if (state == QuizState.busy)
      return ;
    state = QuizState.busy;
    correctlyAnsweredQuestion = [];
    var questions = await _prepareQuestion();
    _questionsIterator = questions.iterator;
    _questionsIterator.moveNext();
    currentQuestionNumber = 0;
    totalQuestionNumber = questions.length;
    state = QuizState.inProgress;
  }

  ///
  void addCorrectlyAnsweredQuestion(QuizQuestion question) {
    correctlyAnsweredQuestion.add(question);
  }

  ///
  bool nextRound() {
    bool res = _questionsIterator.moveNext();
    if (res) {
      currentQuestionNumber += 1;
    } else {
      state = QuizState.finished;
    }
    notifyListeners();
    return res;
  }

  ///
  Future<List<QuizQuestion>> _prepareQuestion() async {
    var questions = [];
    try {
      questions = await _localRepo.getQuestions(count: 10, themes: config.themes, difficulty: config.difficultyData);
    } catch (e) {
      print(e);
    }

    if (questions == null || questions.isEmpty) {
      state = QuizState.error;
      return Future.error(null);
    } 
    for (var q in questions) {
      q.answers.shuffle();
      int i = 0;
      while (q.answers.length > 4 && i < q.answers.length) {
        if (!q.answers[i].isCorrect)
          q.answers.removeAt(i);
        i += 1;
      }
    }
    return questions;
  }
}
