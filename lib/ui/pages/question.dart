import 'dart:io';

import 'package:app/models/models.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/widgets/flex_spacer.dart';
import 'package:app/ui/widgets/surface_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:app/main.dart';
import 'package:path_provider/path_provider.dart';

/// No need to randomize
/// No need to limit question lenght
class QuestionView extends StatefulWidget {

  final QuizQuestion question;
  final bool showResult;
  final Function(QuizAnswer) onAnswerSelected;
  final int totalNumber;
  final int currentNumber;


  QuestionView({
    @required this.question, 
    @required this.currentNumber,
    @required this.totalNumber,
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
              QuestionNumber(
                current: widget.currentNumber, 
                max: widget.totalNumber,
              ),
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
    switch (entitled.type) {
      case ResourceType.IMAGE:
        return buildImage(context);
        break;
      case ResourceType.TEXT:
      default:
        return buildText(context);
    }
  }

  Widget buildText(BuildContext context) {
    return Text(
      entitled.resource, 
      style: TextStyle(fontSize: 30),
    );
  }

  Widget buildImage(BuildContext context) {
    return FutureBuilder(
      future: _localPath,
      builder: (context, snap) {
        if (snap.hasData) {
          return Image.file(File(entitled.resource));
        } else {
          return CircularProgressIndicator();
        }
      }
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}



class AnswerList extends StatelessWidget {

  final List<QuizAnswer> answers;
  final Function(QuizAnswer) onSelected;
  final QuizAnswer selectedAnswer;

  AnswerList({@required this.answers, this.onSelected, this.selectedAnswer});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: answers.map(
        (a) => Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(bottom: Dimens.smallSpacing),
            child: Answer(
              answer: a,
              onSelected: onSelected == null ? null : () => onSelected(a),
              isSelected: selectedAnswer != null && a == selectedAnswer && !a.isCorrect 
            ),
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
    var backColor = Theme.of(context).colorScheme.surface;
    var textColor = Theme.of(context).colorScheme.onSurface;
    if (showResult && answer.isCorrect) {
      backColor = Theme.of(context).colorScheme.success;
      textColor = Theme.of(context).colorScheme.onSuccess;
    }
    if (showResult && isSelected && !answer.isCorrect) {
      backColor = Theme.of(context).colorScheme.error;
      textColor = Theme.of(context).colorScheme.onError;
    }
    
    return SurfaceCard(
      onPressed: onSelected,
      color: backColor,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.subtitle1.apply(color: textColor),
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