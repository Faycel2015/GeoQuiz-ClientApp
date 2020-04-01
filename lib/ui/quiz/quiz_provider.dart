import 'dart:async';

import 'package:app/models/models.dart';
import 'package:app/services/local_database_service.dart';
import 'package:app/ui/homepage/homepage.dart';
import 'package:flutter/widgets.dart';

class QuizConfig {

  Set<QuizTheme> themes;
  DifficultyData difficultyData;

  QuizConfig({this.themes, this.difficultyData});
}

enum QuizState {
  /// nothin happened
  idle,

  /// loading questions
  busy,

  /// party in progress
  inProgress,

  /// party finished
  finished,
}


class QuizProvider extends ChangeNotifier {

  final ILocalDatabaseRepository _localRepo;

  var _state = QuizProviderState.IDLE;
  QuizProviderState get state => _state;
  set state(state) {
    _state = state;
    notifyListeners();
  }

  final QuizConfig config;
  Iterator<QuizQuestion> _questionsIterator;

  List<QuizQuestion> correctlyAnsweredQuestion = [];
  QuizQuestion get currentQuestion => _questionsIterator?.current;
  int totalQuestionNumber = 0;
  int currentQuestionNumber = 0; 
  

  QuizProvider({
    ILocalDatabaseRepository localDbService,
    this.config
  }) : _localRepo = localDbService;
  

  // 0 < difficulty < 100
  Future prepareGame() async {
    if (state == QuizProviderState.IN_PROGRESS)
      return ;
    state = QuizProviderState.IN_PROGRESS;
    correctlyAnsweredQuestion = [];
    var questions = await _prepareQuestion();
    _questionsIterator = questions.iterator;
    _questionsIterator.moveNext();
    currentQuestionNumber = 0;
    totalQuestionNumber = questions.length;
    state = QuizProviderState.PREPARED;
  }


  void addCorrectlyAnsweredQuestion(QuizQuestion question) {
    correctlyAnsweredQuestion.add(question);
  }


  bool nextRound() {
    bool res = _questionsIterator.moveNext();
    currentQuestionNumber += 1;
    notifyListeners();
    return res;
  }




  Future<List<QuizQuestion>> _prepareQuestion() async {
    var questions = [];
    try {
      questions = await _localRepo.getQuestions(count: 10, themes: config.themes, difficulty: config.difficultyData);
    } catch (e) {
      print(e);
    }

    if (questions == null || questions.isEmpty) {
      state = QuizProviderState.ERROR;
      return Future.error(null);
    } 
    for (var q in questions) {
      q.answers.shuffle();
      int i = 0;
      while (q.answers.length > 4 && i < q.answers.length) {
        if (!q.answers[i].isCorrect)
          q.answers.removeAt(i);
        i++;
      }
    }
    return questions;
  }
}




enum QuizProviderState {
  IDLE,
  IN_PROGRESS,
  PREPARED,
  ERROR,
}