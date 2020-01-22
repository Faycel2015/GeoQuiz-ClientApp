import 'package:app/models/models.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:flutter/widgets.dart';


class ThemesProvider extends ChangeNotifier {

  final SQLiteLocalDatabaseRepository _localRepo;

  ThemesProvider({@required SQLiteLocalDatabaseRepository localRepo}) : _localRepo = localRepo;

  List<QuizTheme> themes;
  bool error = false;


  loadThemes() async {
    themes = await _localRepo.getThemes();
    notifyListeners();
  }

}