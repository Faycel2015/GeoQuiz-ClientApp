import 'package:app/logic/progression_provider.dart';
import 'package:app/logic/quiz_provider.dart';
import 'package:app/models/progression.dart';
import 'package:app/ui/pages/home/homepage.dart';
import 'package:app/ui/pages/quiz/quiz.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/widgets/button.dart';
import 'package:app/ui/widgets/flex_spacer.dart';
import 'package:app/ui/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
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
          FlexSpacer.big(),
          Consumer<LocalProgressionProvider>(
            builder: (_, localProgression, __) => LocalProgressionsList(
              progressions: localProgression.progressions.values.toList(),
            ),
          ),
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
    await Provider.of<QuizProvider>(context, listen: false).reinitForReplay();
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


class LocalProgressionsList extends StatelessWidget {

  final List<QuizThemeProgression> progressions;

  LocalProgressionsList({@required this.progressions}) {
    // progressions.sort();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Dimens.borderRadius
      ),
      padding: EdgeInsets.all(Dimens.surfacePadding),
      child: LayoutBuilder(
        builder: (_, constraints) => Wrap(
            spacing: Dimens.normalSpacing,
            direction: Axis.vertical,
            children: progressions.map((p) => 
              SizedBox(
                width: constraints.maxWidth,
                child: Row(
                  children: <Widget>[
                    SvgPicture.string(
                      p.theme.icon, 
                      height: 35, 
                      color: Color(p.theme.color)
                    ),
                    FlexSpacer.small(),
                    Expanded(
                      child: ProgressBar(
                        percentage: p.percentage,
                        color: Color(p.theme.color),
                      ),
                    ),
                  ],
                )
              )
            ).toList(),
          ),
        ),
    );
  }
}