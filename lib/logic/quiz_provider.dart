import 'dart:async';

import 'package:app/models/models.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:app/ui/pages/home/homepage.dart';
import 'package:flutter/widgets.dart';

class QuizConfig {

  Set<QuizTheme> themes;
  DifficultyData difficultyData;

  QuizConfig({this.themes, this.difficultyData});
}


class QuizProvider extends ChangeNotifier {

  final ILocalDatabaseRepository _localRepo;

  var _state = QuizProviderState.IDLE;
  QuizProviderState get state => _state;
  set state(state) {
    _state = state;
    notifyListeners();
  }

  QuizConfig _config;
  Iterator<QuizQuestion> _questionsIterator;

  List<QuizQuestion> correctlyAnsweredQuestion = [];
  QuizQuestion get currentQuestion => _questionsIterator?.current;
  int totalQuestionNumber = 0;
  int currentQuestionNumber = 0; 
  

  QuizProvider({
    ILocalDatabaseRepository localRepo
  }) : _localRepo = localRepo;
  

  // 0 < difficulty < 100
  Future prepareGame(QuizConfig config) async {
    if (state == QuizProviderState.IN_PROGRESS)
      return ;
    state = QuizProviderState.IN_PROGRESS;
    _config = config;
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


  Future reinitForReplay() async {
    await prepareGame(_config);
  }


  Future<List<QuizQuestion>> _prepareQuestion() async {
    var questions = [];
    try {
      questions = await _localRepo.getQuestions(count: 10, themes: _config.themes);
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