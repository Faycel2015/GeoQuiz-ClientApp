import 'package:app/locator.dart';
import 'package:app/logic/progression_provider.dart';
import 'package:app/logic/quiz_provider.dart';
import 'package:app/logic/startup_checker.dart';
import 'package:app/logic/themes_provider.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/local_progression_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:app/ui/pages/home/homepage.dart';
import 'package:app/ui/pages/start_up.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';



/// Entry point for the application, it will basically run the app.
/// 
/// The app is wrapped in a [MultiProvider] widget to provide [Provider]s to the
/// tree. The main application widget is [GeoQuizApp].
/// 
/// [Provider] can then be used with [Consumer] widget or simply by retreive
/// the instance : `Provider.of<[provider class]>(context)`.
///
/// We retrieve repositories to use in the app thanks to the [locator] global
/// instance that inject our dependencies inside the different providers.
void main() async {
  setupServiceLocator();

  // WidgetsFlutterBinding.ensureInitialized();
  // await deleteDatabase("database.db");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StartUpCheckerProvider>(
          create: (context) => StartUpCheckerProvider(
            localRepo: locator<ILocalDatabaseRepository>(),
            remoteRepo: locator<IRemoteDatabaseRepository>(),
          )..performStartUpProcess()
        ),
        ChangeNotifierProvider<ThemesProvider>(
          create: (context) => ThemesProvider(
            localRepo: locator<ILocalDatabaseRepository>(),
          )
        ),
        ChangeNotifierProvider<QuizProvider>(
          create: (context) => QuizProvider(
            localRepo: locator<ILocalDatabaseRepository>(),
          )
        ),
        ChangeNotifierProvider<LocalProgressionProvider>(
          create: (context) => LocalProgressionProvider(
            progressionRepo: locator<ILocalProgressionRepository>(),
            localDbRepo: locator<ILocalDatabaseRepository>()
          )..loadProgressions(),
        )
      ],
      child: GeoQuizApp(),
    )
  );
} 



/// Main widget for the application. 
/// 
/// It build a [MaterialApp] to define the app title, the theme and the home 
/// widget.
/// 
/// The home widget depends of the [StartUpCheckerProvider] state.
/// Depending on the [StartUpCheckerProvider.readyToStart] properties
/// we build the [StartUpView] or the [HomePage].
class GeoQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,

      theme: geoQuizTheme,
  
      home: Consumer<StartUpCheckerProvider>(
        builder: (context, startUpChecker, _) {
          if (!startUpChecker.readyToStart) {
            return StartUpView(error: startUpChecker.error);
          } else {
            loadTheme(context);
            return HomePage();
          }
        }
      ),
      
    );
  }

  /// We scheduled a microtask to wait previous Provider asynchronous tasks
  /// finished
  loadTheme(context) {
    Future.microtask(
      () => Provider.of<ThemesProvider>(context, listen: false).loadThemes()
    );
  }
}



/// Extension of [ColorScheme] methods with [success] color
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
  Color get success => const Color(0xFF28a745);
  Color get onSuccess => Colors.white;
}



/// See "documentation" repo to know more about the app theming
/// 
/// Flutter is actually migrating color theming from ThemeData properties to
/// [ColorScheme]. Some widgets still use ThemeData color properties so there
/// are some redondant color definition ... Ultimately, there should no longer 
/// be color properties (e.g. [ThemeData.primaryColor] is replaced by
/// [ThemeData.colorScheme.primary])
/// 
/// Note: ThemeData are extended with extension method (see [GeoQuizColorScheme])
///       to add success color as it is no currently parts of the material
///       theming colors.
/// 
/// See https://github.com/GeoQuiz-v2/documents
/// See https://github.com/flutter/flutter/issues/36624#issuecomment-513863862
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
