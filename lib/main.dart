import 'package:app/logic/quiz_provider.dart';
import 'package:app/logic/startup_checker.dart';
import 'package:app/logic/themes_provider.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/shared/strings.dart';
import 'package:app/ui/views/homepage.dart';
import 'package:app/ui/views/start_up.dart';
import 'package:app/ui/widgets/basic_scroll_without_glow.dart';
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
/// We also create our repository objects before to launch the app, and we give 
/// hese repositories to the providers who need it. This prevents having 
/// singletons with global states shared throughout the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var localRepo = SQLiteLocalDatabaseRepository();
  var remoteRepo = FirebaseRemoteDatabaseRepository();

  // await deleteDatabase("database.db");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StartUpCheckerProvider>(create: (context) => StartUpCheckerProvider(
          localRepo: localRepo,
          remoteRepo: remoteRepo,
        )..performStartUpProcess()),
        ChangeNotifierProvider<ThemesProvider>(create: (context) => ThemesProvider(
          localRepo: localRepo,
        )),
        ChangeNotifierProvider<QuizProvider>(create: (context) => QuizProvider(
          localRepo: localRepo,
        )),
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
/// we build the [StartUpView] or the [HomepageView].
class GeoQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,

      theme: geoQuizTheme,
  
      home: ScrollConfiguration(
        behavior: BasicScrollWithoutGlow(), // to remove glowing animation for all scrollable widgets 
        child: Consumer<StartUpCheckerProvider>(
          builder: (context, startUpChecker, _) {
            if (!startUpChecker.readyToStart) {
              return StartUpView(error: startUpChecker.error);
            } else {
              loadTheme(context);
              return HomepageView();
            }
          }
        ),
      ),
    );
  }

  loadTheme(context) {
    Future.microtask(
      () => Provider.of<ThemesProvider>(context, listen: false).loadThemes()
    );
  }
}



/// See "documentation" repo to know more about the app theming
/// https://github.com/GeoQuiz-v2/documents
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
    title: TextStyle(fontSize: 37, height: 1.0, shadows: [Dimens.textShadow]),
    body1: TextStyle(fontSize: 16, shadows: [Dimens.textShadow])
  ).apply(bodyColor: Colors.white))
);