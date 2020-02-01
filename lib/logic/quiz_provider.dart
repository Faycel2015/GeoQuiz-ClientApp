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
  Iterator _questionsIterator;
  
  QuizQuestion get currentQuestion => _questionsIterator?.current;
  

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
      
    _questionsIterator = _questions.iterator;
    _questionsIterator.moveNext();

    state = QuizProviderState.PREPARED;
  }


  nextRound() {
    _questionsIterator.moveNext();
    notifyListeners();
  }
}


enum QuizProviderState {
  IDLE,
  IN_PROGRESS,
  PREPARED,
  ERROR,
}