import 'package:app/models/models.dart';


/// Wrapper to stored static data of the app
/// 
/// Static data are the themes and questions, see the specifications to know 
/// more.
/// It is just use to prevent long constructor / method paramaters
class DatabaseContentWrapper {
  List<QuizQuestion> questions;
  List<QuizTheme> themes;
  
  DatabaseContentWrapper({this.questions, this.themes});
}
