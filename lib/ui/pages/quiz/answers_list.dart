import 'package:app/models/models.dart';
import 'package:app/main.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/widgets/surface_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnswersList extends StatelessWidget {
  final List<QuizAnswer> answers;
  final Function(QuizAnswer) onSelected;
  final QuizAnswer selectedAnswer;

  AnswersList({
    Key key, 
    @required this.answers, 
    this.onSelected, 
    this.selectedAnswer
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.screenMarginX),
      child: Column(
        children: answers.map(
          (a) => Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(bottom: Dimens.smallSpacing),
              child: AnswerItem(
                answer: a,
                onSelected: onSelected == null ? null : () => onSelected(a),
                isSelected: selectedAnswer != null && a == selectedAnswer && !a.isCorrect 
              ),
            ),
          )
        ).toList(),
      ),
    );
  }
}


class AnswerItem extends StatelessWidget {

  final QuizAnswer answer;
  final Function onSelected;
  final bool isSelected;
  bool get showResult => onSelected == null;

  AnswerItem({@required this.answer, @required this.onSelected, this.isSelected = false});

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