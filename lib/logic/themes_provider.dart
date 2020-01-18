import 'package:app/models/models.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:flutter/widgets.dart';


class QuizProvider extends ChangeNotifier {

  final SQLiteLocalDatabaseRepository _localRepo;

  QuizProvider({@required SQLiteLocalDatabaseRepository localRepo}) : _localRepo = localRepo;

  List<QuizTheme> themes;


  loadThemes() async {
    themes = await _localRepo.getThemes();
    notifyListeners();
  }

}