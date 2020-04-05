import 'dart:math';

import 'package:app/src/router.dart';
import 'package:app/src/ui/quiz/quiz.dart';
import 'package:app/src/ui/quiz/quiz_provider.dart';
import 'package:app/src/ui/shared/res/dimens.dart';
import 'package:app/src/ui/shared/widgets/button.dart';
import 'package:app/src/ui/shared/widgets/flex_spacer.dart';
import 'package:app/src/ui/shared/widgets/scroll_view_no_effect.dart';
import 'package:app/src/ui/themes/themes_progress_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:app/src/theme.dart';

/// Page that dislays the results of a game and the new overall theme progress.
/// 
/// So, it builds the following widgets :
///  * [QuizScore], which disaply the game results.
///  * [ThemesProgressList], which display the overall theme progress.
///  * [ResultsButtonList], wich display at the bottom of the widget two buttons
///    to replay or to return to home.
///
class ResultsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Dimens.screenMargin,
      child: Stack(
        children: <Widget>[
          ScrollViewNoEffect(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Results", 
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  FlexSpacer.big(),
                  Center(
                    child: QuizScore()
                  ),
                  FlexSpacer.big(),
                  ThemesProgressList(),
                ],
              ),
            ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ResultsButtonList(),
          )
        ],
      )
    );
  }
}

/// Display the score of the game.
/// 
/// There are two elements :
///  * disks green/red in a row that shows the correct / incorrect questions.
///  * text that tells the number of correct questions.
/// 
/// For the row of disks, the default diameter if 20.0. But if this diameter is
/// too big for the device screen, the diameter is the maximum width that each
/// disk can take.
class QuizScore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        Row(
          children: quizProvider.results.map(
            (e) => Expanded(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  var diameter = min(constraints.maxWidth, 20.0);
                  return Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: e ? colorScheme.success : colorScheme.error
                    ),
                  );
                } 
              ),
            )
          ).toList(),
        ),
        FlexSpacer.small(),
        Text(
          "${quizProvider.correctlyAnsweredQuestion.length} correct answers",
          style: Theme.of(context).textTheme.headline3,
        ),
      ],
    );
  }
}

/// Display a button to relaunch a game and a button to renu to home.
class ResultsButtonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Button(
          icon: Icon(Icons.replay), 
          label: "Replay (same configuration)",
          onPressed: () => onReplay(context), 
        ),
        FlexSpacer.small(),
        Button(
          icon: Icon(Icons.home),
          label: "Home",
          light: true,
          onPressed: () => onHome(context),
        )
      ],
    );
  }

  onReplay(context) async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    Navigator.pushReplacementNamed(
      context, 
      QuizPage.routeName, 
      arguments: quizProvider.config
    );
  }

  onHome(context) {
    Router.returnToHome(context);
  }
}