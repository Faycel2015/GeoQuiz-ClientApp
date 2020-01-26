
import 'dart:async';

import 'package:app/logic/quiz_provider.dart';
import 'package:app/ui/views/question.dart';
import 'package:app/ui/views/results.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';


class QuizView extends StatefulWidget {
  @override
  _QuizViewState createState() => _QuizViewState();
}


class _QuizViewState extends State<QuizView> {

  bool showResult = false;

  Timer _questionTimer;
  Timer _resultTimer;


  @override
  void dispose() {
    _questionTimer?.cancel();
    _resultTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, _) {
        final currentQuestion = quizProvider.currentQuestion;
        if (currentQuestion != null) {
          startQuestionTimer();
          return QuestionView(
            question: currentQuestion,
            showResult: showResult,
          );
        }
        return ResultsView();
      } 
    );
  }

  startQuestionTimer() {
    _questionTimer = Timer(Duration(seconds: 4), () {
      startResultTimer();
    });
  }

  startResultTimer() {
    setState(() {
      showResult = true;
    });
    _resultTimer = Timer(Duration(seconds: 2), () {
      setState(() {
        showResult = false;
      });
      Provider.of<QuizProvider>(context, listen: false).nextRound();
    });
  }
}

