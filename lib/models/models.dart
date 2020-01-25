/// Note: there is no toMap or fromMap method, it's just data class without
/// any logic inside !!! 
/// We prefer using the adapter pattern to adapt our database object to these 
/// object models.
/// These adapters are in the repository that handle source data
/// It is more flexible and maintenable as we wan change our repository 
/// (structure, platform, etc.) as we want, it do not affect our models (because 
/// he doesn't have to)


/// Represents a theme
class QuizTheme {
  String id;
  String title;
  String entitled;
  String icon;
  int color;
}


/// Represtents a question
class QuizQuestion {
  String id;
  QuizTheme theme;
  String entitled;
  ResourceType entitledType;
  List<String> answers;
  ResourceType answersType;
  int difficulty;
}


/// Suppoted ressource type
enum ResourceType {
  TEXT,
  IMAGE,
  LOCATION,
}