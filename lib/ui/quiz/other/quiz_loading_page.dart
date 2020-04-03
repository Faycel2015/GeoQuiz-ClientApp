import 'package:app/ui/shared/widgets/flex_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Widget to indicate that questions generation is still in loading
/// 
/// Simply display a circular progress indicator with a text indicator
class FetchingQuestionsInProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Loading questions"),
          FlexSpacer.big(),
          CircularProgressIndicator(),
        ],
      )
    );
  }
}