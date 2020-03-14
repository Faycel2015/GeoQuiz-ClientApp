import 'package:app/models/models.dart';
import 'package:app/models/progression.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/local_progression_repository.dart';
import 'package:flutter/widgets.dart';


class LocalProgressionProvider extends ChangeNotifier {

  ILocalProgressionRepository _progressionRepo;
  ILocalDatabaseRepository _databaseRepo;

  Map<QuizTheme, QuizThemeProgression> progressions;


  LocalProgressionProvider({
    @required ILocalProgressionRepository progressionRepo
  }) : _progressionRepo = progressionRepo;  


  /// Notify clients
  loadProgressions() async {
    var themes = await _databaseRepo.getThemes();
    progressions = await _progressionRepo.retrieveProgressions(themes);
    notifyListeners();
  }

  /// Throw an exception if an error occured
  updateProgressions(List<QuizQuestion> questions) async {
    await _progressionRepo.addQuestions(questions);
  }
}