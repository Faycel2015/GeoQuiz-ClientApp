import 'package:app/logic/quiz_provider.dart';
import 'package:app/ui/views/homepage.dart';
import 'package:app/ui/views/quiz.dart';
import 'package:app/ui/widgets/button.dart';
import 'package:app/ui/widgets/flex_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';


class ResultsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Results", style: Theme.of(context).textTheme.title,),
        FlexSpacer(),
        Center(child: QuizScore()),
        Expanded(child: Container()),
        Center(child: ResultsButtonList())
      ],
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
    _goTo(context, QuizView());
  }

  onHome(context) {
    _goTo(context, HomepageView());
  }

  _goTo(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => page
    ));
  }
}