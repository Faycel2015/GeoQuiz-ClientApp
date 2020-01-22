import 'package:app/logic/database_verification_provider.dart';
import 'package:app/logic/themes_provider.dart';
import 'package:app/repositories/local_database_repository.dart';
import 'package:app/repositories/remote_database_repository.dart';
import 'package:app/ui/shared/strings.dart';
import 'package:app/ui/views/homepage.dart';
import 'package:app/ui/views/start_up.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


/// Entry point for the application, it will basically run the app.
/// 
/// The app is wraped with a [MultiProvider] widget to provide [Provider]
/// to the tree. The main application widget is [GeoQuizApp]
///
/// We also create our repositories implementation before to launch the app,
/// and we give these repositories to the providers who need it. This prevents 
/// having singletons with global states shared throughout the application.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  var localRepo = SQLiteLocalDatabaseRepository();
  var remoteRepo = FirebaseRemoteDatabaseRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DatabaseVerificationProvider>(create: (context) => DatabaseVerificationProvider(
          localRepo: localRepo,
          remoteRepo: remoteRepo,
        )),
        ChangeNotifierProvider<ThemesProvider>(create: (context) => ThemesProvider(
          localRepo: localRepo,
        ))
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

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: Consumer<DatabaseVerificationProvider>(
        builder: (context, provider, _) => (!provider.readyToStart)
          ? StartUpView(error: provider.error)
          : HomepageView()
      ),
    );
  }
}



