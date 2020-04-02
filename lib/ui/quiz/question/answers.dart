import 'package:app/main.dart';
import 'package:app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';



abstract class AnswerItem extends StatelessWidget {

  final QuizAnswer answer;
  final Function onSelected;
  final bool isSelected;
  bool get showResult => onSelected == null;

  AnswerItem(
    {@required this.answer, 
    @required this.onSelected, 
    this.isSelected = false
  });

  Color frontColor(context) {
    var colorScheme = Theme.of(context).colorScheme;
    var frontColor = colorScheme.onSurface;
    if (showResult && answer.isCorrect)
      frontColor = colorScheme.onSuccess;
    if (showResult && isSelected && !answer.isCorrect)
      frontColor = colorScheme.onError;
    return frontColor;
  }

  Color backColor(context) {
    var colorScheme = Theme.of(context).colorScheme;
    var backColor = colorScheme.surface;
    if (showResult && answer.isCorrect)
      backColor = colorScheme.success;
    if (showResult && isSelected && !answer.isCorrect)
      backColor = colorScheme.error;
    return backColor;
  }
}