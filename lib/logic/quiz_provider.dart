import 'dart:async';

import 'package:app/models/models.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:flutter/widgets.dart';


class QuizProvider extends ChangeNotifier {

  final LocalDatabaseRepository _localRepo;

  var _state = QuizProviderState.IDLE;
  QuizProviderState get state => _state;
  set state(state) {
    _state = state;
    notifyListeners();
  }

  Set<QuizTheme> _themes;
  List<QuizQuestion> _questions;
  Iterator<QuizQuestion> _questionsIterator;
  int goodAnswers = 0;
  
  QuizQuestion get currentQuestion => _questionsIterator?.current;
  int get totalNumber => _questions.length;
  int get currentNumber => _questions.indexOf(_questionsIterator.current) + 1; 
  

  QuizProvider({LocalDatabaseRepository localRepo}) : _localRepo = localRepo;
  

  Future<void> prepareGame(Set<QuizTheme> selectedThemes) async {
    if (state == QuizProviderState.IN_PROGRESS)
      return ;
    state = QuizProviderState.IN_PROGRESS;
    _questions = null;
    _questionsIterator = null;
    _themes = selectedThemes;

    try {
      _questions = await _localRepo.getQuestions(count: 10, themes: selectedThemes);
    } catch (e) {}

    if (_questions == null || _questions.isEmpty) {
      state = QuizProviderState.ERROR;
      return Future.error(null);
    }
    _prepareQuestion();
      
    _questionsIterator = _questions.iterator;
    _questionsIterator.moveNext();

    state = QuizProviderState.PREPARED;
  }

  void updateScore(bool correct) {
    goodAnswers += (correct ? 1 : 0);
  }

  void nextRound() {
    _questionsIterator.moveNext();
    notifyListeners();
  }

  Future<void> reinit() async {
    await prepareGame(this._themes);
  }


  _prepareQuestion() {
    for (var q in _questions) {
      q.answers.shuffle();
      int i = 0;
      while (q.answers.length > 4 && i < q.answers.length) {
        if (!q.answers[i].isCorrect)
          q.answers.removeAt(i);
        i++;
      }
    }
  }





}




enum QuizProviderState {
  IDLE,
  IN_PROGRESS,
  PREPARED,
  ERROR,
}