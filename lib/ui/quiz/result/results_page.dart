import 'package:app/ui/homepage/homepage.dart';
import 'package:app/ui/quiz/quiz.dart';
import 'package:app/ui/quiz/quiz_provider.dart';
import 'package:app/ui/shared/res/dimens.dart';
import 'package:app/ui/shared/widgets/button.dart';
import 'package:app/ui/shared/widgets/flex_spacer.dart';
import 'package:app/ui/themes/themes_progress_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';


class ResultsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Dimens.screenMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Results", style: Theme.of(context).textTheme.headline1,),
          FlexSpacer(),
          Center(child: QuizScore()),
          FlexSpacer(),
          ThemesProgressList(),
          Expanded(child: Container()),
          Center(child: ResultsButtonList())
        ],
      ),
    );
  }
}

class QuizScore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    return Text("${quizProvider.correctlyAnsweredQuestion.length} good answers");

  }
}

class ResultsButtonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Button(
          icon: Icon(Icons.replay), 
          label: "Replay (same configuration)",
          onPressed: () => onReplay(context), 
        ),
        FlexSpacer(),
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
    var provider = Provider.of<QuizProvider>(context, listen: false);
    Navigator.pushReplacementNamed(
      context, 
      QuizPage.routeName, 
      arguments: provider.config
    );
  }

  onHome(context) {
    Navigator.pushReplacementNamed(context, HomePage.routeName);
  }
}