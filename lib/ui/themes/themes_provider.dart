import 'package:app/models/models.dart';
import 'package:app/services/local_database_service.dart';
import 'package:app/services/local_progression_service.dart';
import 'package:flutter/widgets.dart';

///
enum ThemeProviderState {
  ///
  not_init,

  ///
  init,

  ///
  error,
}

///
///
///
class ThemesProvider extends ChangeNotifier {
  ///
  ThemesProvider({
    @required ILocalDatabaseRepository localRepo,
    @required ILocalProgressionRepository progressRepo,
  }) : _localRepo = localRepo,
       _progressRepo = progressRepo;

  ///
  final ILocalDatabaseRepository _localRepo;

  ///
  final ILocalProgressionRepository _progressRepo;

  ///
  List<QuizTheme> themes;
  
  ///
  ThemeProviderState state = ThemeProviderState.not_init;

  ///
  loadThemes() async {
    state = ThemeProviderState.not_init;
    try {
      themes = await _localRepo.getThemes();
    } catch(_) {
      state = ThemeProviderState.error;
    }
    state = ThemeProviderState.init;
    notifyListeners();
  }

  /// Throw an exception if an error occured
  updateProgressions(List<QuizQuestion> questions) async {
    await _progressRepo.addQuestions(questions);
    loadThemes();
  }
}


