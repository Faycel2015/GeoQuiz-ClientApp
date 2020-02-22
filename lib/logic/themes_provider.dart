import 'package:app/models/models.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:flutter/widgets.dart';


class ThemesProvider extends ChangeNotifier {

  final ILocalDatabaseRepository _localRepo;

  List<QuizTheme> themes;

  var _state = ThemeProviderState.NOT_INIT;
  ThemeProviderState get state => _state;
  set state(state) {
    _state = state;
    notifyListeners();
  }

  ThemesProvider({
    @required ILocalDatabaseRepository localRepo
  }) : _localRepo = localRepo;


  loadThemes() async {
    state = ThemeProviderState.NOT_INIT;
    try {
      themes = await _localRepo.getThemes();
    } catch(_) {
      state = ThemeProviderState.ERROR;
    }
    state = ThemeProviderState.INIT;
  }
}


enum ThemeProviderState {
  NOT_INIT,
  INIT,
  ERROR,
}