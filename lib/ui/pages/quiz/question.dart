import 'dart:io';
import 'dart:ui';

import 'package:app/models/models.dart';
import 'package:app/ui/pages/quiz/answers_list.dart';
import 'package:app/ui/pages/quiz/answers_map.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/widgets/flex_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';


/// No need to randomize
/// No need to limit question lenght
class QuestionView extends StatefulWidget {

  final QuizQuestion question;
  final bool showResult;
  final Function(QuizAnswer) onAnswerSelected;
  final int totalNumber;
  final int currentNumber;
  final Function onReady;


  QuestionView({
    Key key,
    @required this.question, 
    @required this.currentNumber,
    @required this.totalNumber,
    this.onAnswerSelected, 
    this.onReady,
    this.showResult = false,
  }) : super(key: key);

  @override
  _QuestionViewState createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {

  QuizAnswer selectedAnswer;
  bool get ready => _questionEntitledLoaded && _answersLoaded;

  bool _questionEntitledLoaded = false;
  bool _answersLoaded = false;


  @override
  Widget build(BuildContext context) {
    return  Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.screenMarginX),
          child: Row(
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
        ),
        FlexSpacer(),
        QuestionEntitled(
          entitled: widget.question.entitled,
          onCompletelyRendered: () {
            this._questionEntitledLoaded = true;
            if (ready) widget.onReady();
          }
        ),
        FlexSpacer.big(),
        Answers(
          answers: widget.question.answers,
          onSelected: widget.showResult ? null : onSelectedAnswer,
          selectedAnswer: selectedAnswer,
          onCompletelyRendered: () {
            this._answersLoaded = true;
            if (ready) widget.onReady();
          }
        )
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
  final Function onCompletelyRendered;


  QuestionEntitled({@required this.entitled, @required this.onCompletelyRendered});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => onCompletelyRendered());

    Widget child;
    switch (entitled.type) {
      case ResourceType.image:
        child = buildImage(context);
        break;
      case ResourceType.text:
      default:
        child = buildText(context);
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.screenMarginX),
      child: child,
    );
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
          return Image.file(File(entitled.resource), );
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


class Answers extends StatelessWidget {
  final List<QuizAnswer> answers;
  final Function(QuizAnswer) onSelected;
  final QuizAnswer selectedAnswer;
  final Function onCompletelyRendered;

  Answers({
    Key key, 
    @required this.answers, 
    this.onSelected, 
    this.selectedAnswer,
    @required this.onCompletelyRendered
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMap = answers.first.answer.type == ResourceType.location;
    if (isMap) {
      return AnswersMap(
        key: GlobalKey(), // to reset the scroll to the beginning
        answers: answers,
        onSelected: onSelected,
        selectedAnswer: selectedAnswer,
        onLoaded: () => onCompletelyRendered()
      );
    } else {
      onCompletelyRendered();
      return AnswersList(
        answers: answers,
        onSelected: onSelected,
        selectedAnswer: selectedAnswer,
      );
    }
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