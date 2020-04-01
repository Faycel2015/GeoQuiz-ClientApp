import 'package:app/locator.dart';
import 'package:app/router.dart';
import 'package:app/startup/startup_page.dart';
import 'package:app/startup/startup_provider.dart';
import 'package:app/ui/pages/home/homepage.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/shared/strings.dart';
import 'package:app/ui/widgets/base_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

/// Entry point for the application. Set up the [Locator] and create the
/// widget tree.
/// 
/// It runs the app by creating the root widget of the app, the root widget if
/// [GeoQuizApp].
/// 
/// This function is automatically called by the engine, so you don't have to
/// call this function anywhere. The behavior is not defined if you call this
/// function again, as the services and providers are register here, calling
/// this function again will try to re-register the services and provider and
/// will caused an exception.
/// 
/// See also :
/// 
///  * [MaterialApp], which if the root of the application.
///  * [Locator], which if the service locator.
///   
void main() async {
  Locator.setupLocator();
  // WidgetsFlutterBinding.ensureInitialized();
  // await deleteDatabase("database.db");
  runApp(GeoQuizApp());
} 

/// Root of the application, it builds a [MaterialApp].
/// 
/// The material app defined the application title, the theme, and the route
/// generator used to navigate between the different screens. To know more about 
/// the routing, see [Router].
/// 
/// Depending on the [StartUpProvider] state etheir the [Homepage] or the 
/// [StartUpPage] will be displayed (home of the material application).
class GeoQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      theme: geoQuizTheme,
      onGenerateRoute: Router.generateRoute,
      home: BasePage<StartUpProvider>(
        builder: (context, startUpProvider, _) => startUpProvider.isReady
            ? HomePage()
            : StartUpPage(status: startUpProvider.status)
      ),
    );
  }
}

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

