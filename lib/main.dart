import 'package:app/logic/database_verification_provider.dart';
import 'package:app/logic/quiz_provider.dart';
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
/// The app is wraped with a [MultiProvider] widget to provide [Provider]
/// to the tree. The main application widget is [GeoQuizApp]
///
/// We also create our repositories implementation before to launch the app,
/// and we give these repositories to the providers who need it. This prevents 
/// having singletons with global states shared throughout the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var localRepo = SQLiteLocalDatabaseRepository();
  var remoteRepo = FirebaseRemoteDatabaseRepository();

  // await deleteDatabase("database.db");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DatabaseVerificationProvider>(create: (context) => DatabaseVerificationProvider(
          localRepo: localRepo,
          remoteRepo: remoteRepo,
        )),
        ChangeNotifierProvider<ThemesProvider>(create: (context) => ThemesProvider(
          localRepo: localRepo,
        )),
        ChangeNotifierProvider<QuizProvider>(create: (context) => QuizProvider(

        )),
      ],
      child: GeoQuizApp()
    )
  );
} 


/// Main widget for the application. It is just an [StatelessWidget]
/// that builds a [MaterialApp] to define the app title, the theme and
/// the home widget.
/// 
/// The home widget depends of the [DatabaseVerificationProvider] state.
/// Depending on the [DatabaseVerificationProvider.readyToStart] properties
/// we build the [StartUpView] or the [HomepageView].
class GeoQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,

      theme: geoQuizTheme,
  
      home: ScrollConfiguration(
        behavior: BasicScrollWithoutGlow(), // we remove glowing animation for all scrollable widgets 
        child: Consumer<DatabaseVerificationProvider>(
          builder: (context, provider, _) => (!provider.readyToStart)
            ? StartUpView(error: provider.error)
            : HomepageView()
        ),
      ),
    );
  }
}



final geoQuizTheme = ThemeData(
  primaryColor: Color(0xFF4E19C8),
  primaryColorLight: Color(0xFF916DE4),
  primaryIconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
  primaryTextTheme: GoogleFonts.righteousTextTheme(),

  accentColor: Color(0xFFFBC519),
  accentIconTheme: IconThemeData(color: Color(0xFF644F0A)),
  accentTextTheme: GoogleFonts.righteousTextTheme(),

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
    title: TextStyle(fontSize: 45, height: 1.0, shadows: [Dimens.textShadow])
  ).apply(bodyColor: Colors.white))
);