/// Asset names available in the app (see pubspec.yaml) to see declared assets
///
/// To add a new asset:
/// 1. import the asset inside the `assets/` directory
/// 2. include the asset name inside the `pubspec.yaml` file
/// 3. add the asset reference here
/// 
/// With this class asset pahts (or filenames) can be modified with no impact
/// on the UI (except if the file format change).
/// In essence, it avoids hard-coding the names of the assets in our widgets.
/// 
/// Everything is constant, so the constructor is private as it makes no sense 
/// to create an instance of this class.
class Assets {

  Assets._();

  /// Hamburger icon used to display a menu for example 
  static const menu = "assets/menu.svg";
  
  /// Real empty worldmap with all countries (but without names)
  static const worldmap = "assets/worldmap.svg";
  
  /// Marker used to specify a location on a map
  static const marker = "assets/marker.svg";
}