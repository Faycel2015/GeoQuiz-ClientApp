import 'package:app/models/models.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/widgets/flex_spacer.dart';
import 'package:app/ui/widgets/gradient_background.dart';
import 'package:app/ui/widgets/surface_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class QuestionView extends StatelessWidget {

  final QuizQuestion question;
  final bool showResult;

  QuestionView({@required this.question, this.showResult = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Dimens.screenMargin,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: ThemeEntitled(theme: question.theme,)
              ),
              QuestionNumber(current: 1, max: 2,),
            ],
          ),
          FlexSpacer(),
          QuestionEntitled(entitled: question.entitled,),
          FlexSpacer(big: true,),
          AnswerList(answers: question.answers,),
        ],
      ),
    );
  }
}




class ThemeEntitled extends StatelessWidget {
  
  final QuizTheme theme;

  ThemeEntitled({@required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(theme.entitled, style: TextStyle(fontSize: 25));
  }
}



class QuestionEntitled extends StatelessWidget {
    
  final Resource entitled;

  QuestionEntitled({@required this.entitled});

  @override
  Widget build(BuildContext context) {
    return Text(entitled.resource, style: TextStyle(fontSize: 30),);
  }
}



class AnswerList extends StatelessWidget {

  final List<Resource> answers;

  AnswerList({@required this.answers});


  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: answers.map(
        (a) => Padding(
          padding: const EdgeInsets.only(bottom: Dimens.smallSpacing),
          child: Answer(answer: a),
        )
      ).toList(),
    );
  }
}

class Answer extends StatelessWidget {

  final Resource answer;

  Answer({@required this.answer});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      color: Theme.of(context).colorScheme.surface,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.subhead.apply(color: Colors.black),
        child: Text(answer.resource)
      ),
    );
  }
}


class QuestionNumber extends StatelessWidget {
  final int current;
  final int max;

  QuestionNumber({@required this.current, @required this.max});

  @override
  Widget build(BuildContext context) {
    return Text("$current / $max");
  }
}