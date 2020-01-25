import 'package:app/models/models.dart';

class DatabaseContentWrapper {
  List<QuizQuestion> questions;
  List<QuizTheme> themes;
  
  DatabaseContentWrapper({this.questions, this.themes});
}
