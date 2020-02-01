import 'dart:async';

import 'package:app/logic/quiz_provider.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/shared/values.dart';
import 'package:app/ui/views/question.dart';
import 'package:app/ui/views/results.dart';
import 'package:app/ui/widgets/flex_spacer.dart';
import 'package:app/ui/widgets/geoquiz_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';


final timerColorTweenSequence = TweenSequence<Color>([
  TweenSequenceItem(
    weight: 1.0,
    tween: ColorTween(
      begin: Colors.green,
      end: Colors.yellow,
    ),
  ),
  TweenSequenceItem(
    weight: 1.0,
    tween: ColorTween(
      begin: Colors.yellow,
      end: Colors.orange,
    ),
  ),
  TweenSequenceItem(
    weight: 1.0,
    tween: ColorTween(
      begin: Colors.orange,
      end: Colors.red,
    ),
  ),],
);



class QuizView extends StatefulWidget {
  
  final int questionDuration = Values.questionDuration;
  final int resultDuration = Values.resultDuration;

  @override
  _QuizViewState createState() => _QuizViewState();
}


class _QuizViewState extends State<QuizView> {
  
  bool showResult = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(builder: (context, quizProvider, _) {
      final currentQuestion = quizProvider.currentQuestion;
      final backColor = currentQuestion?.theme?.color;
      return GeoQuizLayout(
        // color: backColor != null ? Color(backColor) : null,
        bodyPadding: Dimens.screenMargin,
        body: currentQuestion == null 
        ? ResultsView()
        : Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TimerWidget(
              max: showResult ? widget.resultDuration : widget.questionDuration,
              onFinished: showResult ? nextRound : finishRound,
              key: GlobalKey(),
              tick: 100,
            ),
            FlexSpacer(),
            QuestionView(
              question: currentQuestion,
              showResult: showResult,
              onAnswerSelected: (answer) {
                finishRound();
              },
            ),
          ],
        ),
      );
    });
  }

  finishRound() {
    setState(() {
      showResult = true;
    });
  }

  nextRound() {
    showResult = false;
    Provider.of<QuizProvider>(context, listen: false).nextRound();
  }
}



class TimerWidget extends StatefulWidget {
  final int max;
  final int tick;
  final Function onFinished;
  

  TimerWidget({
    Key key,
    @required this.max, 
    @required this.onFinished,
    this.tick = 500
  }) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}



class _TimerWidgetState extends State<TimerWidget> with SingleTickerProviderStateMixin {

  AnimationController animationController;
  int elapsedTime = 0;

  
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this, 
      duration: Duration(milliseconds: widget.max)
    )..forward().then((_) {
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: animationController,
        builder: (context, _) => Container(
          width: constraints.maxWidth - (constraints.maxWidth * animationController.value),
          height: 10,
          decoration: BoxDecoration(
            color: timerColorTweenSequence.evaluate(AlwaysStoppedAnimation(animationController.value)),
            borderRadius: Dimens.roundedBorderRadius
          ),
        ),
      ),
    );
  }
}
