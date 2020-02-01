/// [String] constants shared across the app UI.
/// 
/// Consider always add strings used in the app in this class to avoids 
/// hard-coded strings spread out in the app widgets.
/// 
/// Everything is constant, so the constructor is private
/// as it makes no sense to create an instance of this class.
class Strings  {
  Strings._();

  // General
  static const String appName = "GeoQuiz";
  static const String loading = "Loading ...";

  // Homepage
  static const String homepageTitle = "Hi,";
  static const String homepageSubtitle = "Time to play !";
  static const String loadingThemes = "Loading ...";
  static const String selectThemes = "Select your themes :";
  static const String launchQuiz = "Let's go";
  static const String quizConfigurationInvalid = "Please select themes to play !";
  static const String quizPreparationError = "Unexpected error occured.";




  // Menu
  static const String menuDonation = "Buy me a coffee";
  static const String menuResetData = "Reset my data";
  static const String menuBugReport = "Report a bug";

}