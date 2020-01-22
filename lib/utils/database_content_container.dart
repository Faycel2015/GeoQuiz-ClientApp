import 'package:app/models/models.dart';

class DatabaseContentContainer {
  List<QuizQuestion> questions;
  List<QuizTheme> themes;
  
  DatabaseContentContainer({this.questions, this.themes});
}
