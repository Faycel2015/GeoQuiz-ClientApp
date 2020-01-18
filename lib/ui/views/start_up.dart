import 'package:app/logic/database_verification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';


class StartUpView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DatabaseVerificationProvider>(
        builder: (context, provider, _) {
          if (provider.startUpVerificationDone ) {
            if (provider.localDatabaseUpToDate && provider.currentLocalDatabaseExists)
              goToHomePage(context);
            else
              return StartUpErrorWidget();
          }
          return Text("loading...");
        }
      ),
    );
  }

  goToHomePage(context) {
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => Text("ok")
    ));
  }
}



class StartUpErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "error"
    );
  }
}