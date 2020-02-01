import 'dart:async';

import 'package:app/logic/quiz_provider.dart';
import 'package:app/models/models.dart';
import 'package:app/ui/views/question.dart';
import 'package:app/ui/views/results.dart';
import 'package:app/ui/widgets/geoquiz_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';



class QuizView extends StatefulWidget {
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
        color: backColor != null ? Color(backColor) : null,
        body: currentQuestion == null 
        ? ResultsView()
        : Column(
          children: <Widget>[
            TimerWidget(
              max: showResult ? 2000 : 6000,
              onFinished: showResult ? nextRound : finishRound,
              key: GlobalKey(),
              tick: 100,
            ),
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



class _TimerWidgetState extends State<TimerWidget> {

  Timer timer;
  int elapsedTime = 0;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        width: constraints.maxWidth * (elapsedTime / widget.max),
        height: 5,
        color: Colors.white,
      ),
    );
  }

  startTimer() {
    timer = Timer.periodic(Duration(milliseconds: widget.tick), (Timer timer) {
      if (elapsedTime >= widget.max) {
        timer.cancel();
        elapsedTime = 0;
        widget.onFinished();
      }
      setState(() => elapsedTime += widget.tick);
    });
  }
}
