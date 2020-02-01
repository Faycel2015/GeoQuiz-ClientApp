/// Values shared across the app UI.
/// 
/// These values are not intended for theming the UI but more to handle the
/// UI behavior. 
/// 
/// Everything is constant, so the constructor is private as it makes no sense 
/// to create an instance of this class.
class Values {
  Values._();

  static const questionDuration = 5000;
  static const resultDuration = 2000;
}