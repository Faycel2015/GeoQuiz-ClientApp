/// Useful values destined to be used by the UI widgets 
/// 
/// These values are not intended for theming the UI but more to handle the
/// UI behavior. See [Dimens] for constants used to modified the app appearance.
/// 
/// Everything is constant, so the constructor is private as it makes no sense 
/// to create an instance of this class.
class Values {

  Values._();

  /// Time in milliseconds to let the user answer the question
  static const questionDuration = 5000;
  
  /// Time in milliseconds to let the user see the correct answer
  static const resultDuration = 1500;
}