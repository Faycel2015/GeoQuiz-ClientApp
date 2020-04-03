import 'package:app/src/ui/shared/res/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

/// Extension of [ColorScheme] to add color related to "success".
/// 
/// Use extension method to this it's the simplest solution (imo).
/// It is not the perfect solution as there are mainly 2 limitations :
/// - it is not possible to have a different colored scheme for another 
///   ThemeData (e.g. light vs dark theme)
/// - It is not possible to create variations of the ColorScheme by using .
///   [ThemeData.copyWith()] function.
///
/// See https://dart.dev/guides/language/extension-methods
extension GeoQuizColorScheme on ColorScheme {
  /// The color used to indicate a succeed operation 
  Color get success => const Color(0xFF28a745);

  /// A color that's clearly legible when drawn on [success].
  Color get onSuccess => Colors.white;
}

/// See "documentation" repo to know more about the app theming.
/// 
/// Flutter is actually migrating color theming from ThemeData properties to
/// [ColorScheme]. Some widgets still use ThemeData color properties so there
/// are some redondant color definition ... Ultimately, there should no longer 
/// be color properties (e.g. [ThemeData.primaryColor] is replaced by
/// [ThemeData.colorScheme.primary]).
/// 
/// NThemeData are extended with extension method (see [GeoQuizColorScheme]) to 
/// add success color as it is no currently parts of the material theming 
/// colors.
/// 
/// See also :
/// 
///  * [App theming](https://github.com/GeoQuiz-v2/documents/blob/master/geoquiz_material_theming.png)
final geoQuizTheme = ThemeData(
  primaryColor: Color(0xFF4E19C8),
  primaryColorLight: Color(0xFF916DE4),
  primaryIconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
  primaryTextTheme: GoogleFonts.righteousTextTheme(),

  accentColor: Color(0xFFFBC519),
  accentIconTheme: IconThemeData(color: Color(0xFF644F0A)),
  accentTextTheme: GoogleFonts.righteousTextTheme(),

  backgroundColor: Color(0xFF4E19C8),
  scaffoldBackgroundColor: Color(0xFF4E19C8),

  colorScheme: ColorScheme(
    primary: Color(0xFF4E19C8),
    primaryVariant: Color(0xFF916DE4),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFFBC519),
    secondaryVariant: Color(0xFFFBC519),
    onSecondary: Color(0xFF644F0A),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF383838),
    error: Color(0xFFE23539),
    onError: Color(0xFFFFFFFF),
    background: Color(0xFF4E19C8),
    onBackground: Color(0xFFFFFFFF),
    brightness: Brightness.dark
  ),
  brightness: Brightness.dark,
  
  textTheme: GoogleFonts.righteousTextTheme(TextTheme(
    headline1: TextStyle(fontSize: 37, height: 1.0, shadows: [Dimens.textShadow]),
    headline2:  TextStyle(fontSize: 19),

    bodyText1: TextStyle(fontSize: 16, shadows: [Dimens.textShadow]),

    subtitle1: TextStyle(fontSize: 16),
    subtitle2: TextStyle(fontSize: 16),

    button: TextStyle(fontSize: 15)
  ).apply(
    bodyColor: Colors.white, 
    displayColor: Colors.white
  ))
);

