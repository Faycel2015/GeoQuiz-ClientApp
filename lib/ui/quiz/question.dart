import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:app/models/models.dart';
import 'package:app/ui/quiz/answers_list.dart';
import 'package:app/ui/quiz/answers_map.dart';
import 'package:app/ui/quiz/quiz.dart';
import 'package:app/ui/shared/res/dimens.dart';
import 'package:app/ui/shared/res/values.dart';
import 'package:app/ui/shared/widgets/flex_spacer.dart';
import 'package:app/ui/shared/widgets/scroll_view_no_effect.dart';
import 'package:app/ui/shared/widgets/will_pop_scope_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';


/// No need to randomize
/// No need to limit question lenght
class QuestionView extends StatefulWidget {
  ///
  QuestionView({
    Key key,
    @required this.question, 
    @required this.currentNumber,
    @required this.totalNumber,
    this.onFinished,
    this.showResult = false,
  }) : super(key: key);

  ///
  final QuizQuestion question;

  ///
  final bool showResult;

  ///
  final int totalNumber;

  ///
  final int currentNumber;
  
  /// answer null if the timer reach the end without selected question
  final Function(QuizAnswer) onFinished;

  @override
  _QuestionViewState createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {

  final GlobalKey<TimerWidgetState> timerKey = GlobalKey<TimerWidgetState>();
  final scrollController = ScrollController();
  QuizAnswer selectedAnswer;
  bool get ready => _questionEntitledLoaded && _answersLoaded;
  bool _questionEntitledLoaded = false;
  bool _answersLoaded = false;

  ///
  _onSelectedAnswer(answer) {
    setState(() => selectedAnswer = answer);
    timerKey.currentState.reset();
    scrollController.animateTo(0, 
      curve: Curves.easeOutQuad, 
      duration: Duration(milliseconds: 500)
    );
    widget.onFinished(answer);
  }

  ///
  _startTimer() {
    var duration = widget.showResult ? Values.resultDuration : Values.questionDuration;
    timerKey.currentState.start(Duration(milliseconds: duration));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScopeWarning(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: Dimens.screenMargin,
              child: TimerWidget(
                key: timerKey, // to restart the animation when the tree is rebuilt
                onFinished: () => _onSelectedAnswer(null),
                animatedColor: !widget.showResult,
                colorSequence: timerColorTweenSequence,
              ),
            ),
          ), 
          ScrollViewNoEffect(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(top: 50),
              child:Column(
                children: <Widget>[
                  Placeholder(fallbackHeight: 400,),
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
                      _questionEntitledLoaded = true;
                      if (ready) _startTimer();
                    }
                  ),
                  FlexSpacer.big(),
                  Answers(
                    answers: widget.question.answers,
                    onSelected: widget.showResult ? null : _onSelectedAnswer,
                    selectedAnswer: selectedAnswer,
                    onCompletelyRendered: () {
                      _answersLoaded = true;
                      if (ready) _startTimer();
                    }
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}




class ThemeEntitled extends StatelessWidget {
  ///
  ThemeEntitled({
    Key key,
    @required this.theme
  }) : super(key: key);

  ///
  final QuizTheme theme;

  @override
  Widget build(BuildContext context) {
    return Text(theme.entitled, style: TextStyle(fontSize: 25));
  }
}



class QuestionEntitled extends StatelessWidget {
  ///
  QuestionEntitled({
    Key key,
    @required this.entitled, 
    @required this.onCompletelyRendered
  });

  /// 
  final Resource entitled;
  
  ///
  final Function onCompletelyRendered;


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
}

///
///
///
class Answers extends StatelessWidget {
  ///
  Answers({
    Key key, 
    @required this.answers, 
    this.onSelected, 
    this.selectedAnswer,
    @required this.onCompletelyRendered
  }) : super(key: key);

  ///
  final List<QuizAnswer> answers;

  ///
  final Function(QuizAnswer) onSelected;

  ///
  final QuizAnswer selectedAnswer;

  ///
  final Function onCompletelyRendered;

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

///
///
///
class QuestionNumber extends StatelessWidget {
  final int current;
  final int max;

  QuestionNumber({@required this.current, @required this.max});

  @override
  Widget build(BuildContext context) {
    return Text("$current / $max");
  }
}