import 'package:app/models/models.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/widgets/flex_spacer.dart';
import 'package:app/ui/widgets/surface_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:app/main.dart';

/// No need to randomize
/// No need to limit question lenght
class QuestionView extends StatefulWidget {

  final QuizQuestion question;
  final bool showResult;
  final Function(QuizAnswer) onAnswerSelected;


  QuestionView({
    @required this.question, 
    this.onAnswerSelected, 
    this.showResult = false,
  });

  @override
  _QuestionViewState createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {

  QuizAnswer selectedAnswer;

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: ThemeEntitled(theme: widget.question.theme,)
            ),
            QuestionNumber(current: 1, max: 2,),
          ],
        ),
        FlexSpacer(),
        QuestionEntitled(entitled: widget.question.entitled,),
        FlexSpacer(big: true,),
        AnswerList(
          answers: widget.question.answers,
          onSelected: widget.showResult ? null : onSelectedAnswer,
          selectedAnswer: selectedAnswer,
        ),
      ],
    );
  }

  onSelectedAnswer(answer) {
    setState(() => selectedAnswer = answer);
    widget.onAnswerSelected(answer);
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

  final List<QuizAnswer> answers;
  final Function(QuizAnswer) onSelected;
  final QuizAnswer selectedAnswer;

  AnswerList({@required this.answers, this.onSelected, this.selectedAnswer});


  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: answers.map(
        (a) => Padding(
          padding: const EdgeInsets.only(bottom: Dimens.smallSpacing),
          child: Answer(
            answer: a,
            onSelected: onSelected == null ? null : () => onSelected(a),
            isSelected: selectedAnswer != null && a == selectedAnswer && !a.isCorrect 
          ),
        )
      ).toList(),
    );
  }
}

class Answer extends StatelessWidget {

  final QuizAnswer answer;
  final Function onSelected;
  final bool isSelected;
  bool get showResult => onSelected == null;

  Answer({@required this.answer, @required this.onSelected, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).colorScheme.surface;
    if (showResult && answer.isCorrect)
      color = Theme.of(context).colorScheme.success;
    if (showResult && isSelected && !answer.isCorrect)
      color = Colors.red;

    return SurfaceCard(
      onPressed: onSelected,
      color: color,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.subhead.apply(color: Colors.black),
        child: Text(answer.answer.resource)
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