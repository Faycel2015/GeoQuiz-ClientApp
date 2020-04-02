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
    @required ILocalDatabaseRepository localRepo
  }) : _localRepo = localRepo;

  ///
  final ILocalDatabaseRepository _localRepo;
  final ILocalProgressionRepository _progressionRepo = null;

  ///
  List<QuizTheme> themes;
  
  ///
  ThemeProviderState state = ThemeProviderState.not_init;


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
    await _progressionRepo.addQuestions(questions);
    // loadProgressions();
  }


  /// Notify clients
  // loadProgressions() async {
  //   var themes = await _databaseRepo.getThemes();
  //   progressions = await _progressionRepo.retrieveProgressions(themes);
  //   notifyListeners();
  // }
}


