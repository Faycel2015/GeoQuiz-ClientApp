import 'package:app/logic/quiz_provider.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/views/homepage.dart';
import 'package:app/ui/views/quiz.dart';
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
          icon: Icons.replay, 
          label: "Replay (same configuration)",
          onPressed: () => onReplay(context), 
        ),
        FlexSpacer(),
        Button(
          icon: Icons.home,
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


class Button extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function onPressed;
  final bool light;

  Button({
    @required this.icon, 
    @required this.label, 
    @required this.onPressed,
    this.light = false
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backColor = light ? colorScheme.primaryVariant : colorScheme.secondary;
    final frontColor = light ? colorScheme.onPrimary : colorScheme.onSecondary;
    return FlatButton.icon(
      icon: Icon(icon), 
      label: Flexible(child: Text(label)),
      color: backColor,
      textColor: frontColor,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      shape: StadiumBorder(),
      onPressed: onPressed, 
    );
  }
}