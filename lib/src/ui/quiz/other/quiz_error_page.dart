import 'package:app/src/router.dart';
import 'package:app/src/ui/shared/widgets/button.dart';
import 'package:app/src/ui/shared/widgets/flex_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Widge to indicate that an error occured to prepare the game
/// 
/// It display an indicator text with a button to return to the home page
class FetchingQuestionsError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("This wasn't supposed to happen 😳"),
          FlexSpacer.big(),
          Button(
            onPressed: () => Router.returnToHome(context),
            icon: Icon(Icons.arrow_back),
            label: "Return to home",
          )
        ],
      ),
    );
  }
}
