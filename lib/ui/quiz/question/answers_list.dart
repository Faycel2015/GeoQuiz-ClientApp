import 'package:app/models/models.dart';
import 'package:app/ui/quiz/question/answers.dart';
import 'package:app/ui/shared/res/dimens.dart';
import 'package:app/ui/shared/widgets/surface_card.dart';
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
              child: ListAnswerItem(
                answer: a,
                onSelected: onSelected == null ? null : () => onSelected(a),
                isSelected: selectedAnswer != null && a == selectedAnswer 
              ),
            ),
          )
        ).toList(),
      ),
    );
  }
}






class ListAnswerItem extends AnswerItem {

  ListAnswerItem({
    QuizAnswer answer, 
    void Function() onSelected, 
    bool isSelected = false
  }) : super(
    answer: answer,
    onSelected: onSelected,
    isSelected: isSelected
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SurfaceCard(
      onPressed: onSelected,
      color: backColor(context),
      child: DefaultTextStyle(
        style: textTheme.subtitle1.apply(color: frontColor(context)),
        child: Text(answer.answer.resource)
      ),
    );
  }
}