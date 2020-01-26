import 'package:app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class QuestionView extends StatelessWidget {

  final QuizQuestion question;
  final bool showResult;

  QuestionView({@required this.question, this.showResult = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              ThemeEntitled(),
              QuestionNumber(),
            ],
          ),
          QuestionEntitled(),
          Answers(),
          Text(showResult.toString()),
          Text(question.entitled),
        ],
      ),
    );
  }
}



class ThemeEntitled extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}

class QuestionEntitled extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}

class Answers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}


class QuestionNumber extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}