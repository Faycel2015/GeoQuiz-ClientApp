import 'package:app/models/models.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:flutter/widgets.dart';


class ThemesProvider extends ChangeNotifier {

  final LocalDatabaseRepository _localRepo;

  List<QuizTheme> themes;
  bool error = false;

  ThemesProvider({
    @required LocalDatabaseRepository localRepo
  }) : _localRepo = localRepo;


  loadThemes() async {
    if (themes == null) {
      themes = await _localRepo.getThemes();
      notifyListeners();
    }
  }

  reset() {
    this.themes = null;
    this.error = false;
  }
}