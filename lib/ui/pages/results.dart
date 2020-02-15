import 'package:app/logic/quiz_provider.dart';
import 'package:app/ui/pages/homepage.dart';
import 'package:app/ui/pages/quiz.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/widgets/button.dart';
import 'package:app/ui/widgets/flex_spacer.dart';
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

    return Text("${quizProvider.goodAnswers} good answers");

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
    await Provider.of<QuizProvider>(context, listen: false).reinit();
    _goTo(context, QuizPage());
  }

  onHome(context) {
    _goTo(context, HomePage());
  }

  _goTo(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => page
    ));
  }
}