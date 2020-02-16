import 'dart:async';

import 'package:app/logic/quiz_provider.dart';
import 'package:app/models/models.dart';
import 'package:app/ui/pages/quiz/question.dart';
import 'package:app/ui/pages/result/results.dart';
import 'package:app/ui/shared/assets.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/shared/values.dart';
import 'package:app/ui/widgets/flex_spacer.dart';
import 'package:app/ui/widgets/geoquiz_layout.dart';
import 'package:app/ui/widgets/scroll_view_no_effect.dart';
import 'package:app/utils/assets_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';


/// TweenSequence used to animate the [TimerWidget] for questions timer
/// 
/// It's a a sequence of [Color] from green to red via yellow and orange as
/// intermediate colors. It's used for a simply linear animation and each
/// tween sequence has the same weight.
final timerColorTweenSequence = TweenSequence<Color>(<TweenSequenceItem<Color>>[
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

/// Total duration to answer a question
final questionDuration = Duration(milliseconds: Values.questionDuration);

/// Total duration to display question results (wrong and bad - if any - answers)
final resultDuration = Duration(milliseconds: Values.resultDuration);



/// Main widget to display the quiz: it's either the question or the result view
///
/// It used the [Consumer] widget to have access to the [QuizProvider] who
/// holds and handle the quiz data (current question, result, selected themes,
/// etc.)
/// If there is an available question the [QuestionView] with a [TimerWidget]
/// are displayed.
/// Else, the [ResultsPage] is display.
/// Note: There is no "intermediate" loading screen as if the game is not
///       finished, the [QuizProvider] provide immediatly the current question 
///       (so it is not an asychronous task).
///       See the [QuizProvider] documentation for more information
/// To summarize :
///   IF current question available
///   |- Column
///     |- TimerWidget
///     |- QuestionView
///   ELSE
///   |- ResultsView()
/// 
/// The widget is a [StatefulWidget] as the QuizProvider DOES NOT handle the
/// timers duration, the result part, etc. The QuizProvider just provide 
/// question, themes and handle results state.
/// So, the widget state is for rebuilt the tree when the question answered time
/// if finished to display correct and - if any - wrong answer.
/// 
/// Timers for question time and questio, result time are handle by a [TimerWidget].
/// Depending on the current state (question or question result time) the appropriate
/// duration is given to the TimerWidget [questionDuration] or [resultDuration].
/// When the timer wiget finished it calls the [TimerWidget.onFinished] function
/// which is passed as parameter (see the [TimerWidget] documentation).
/// A new key is given to the [TimerWidget] everytime it is rebuilt to re-start
/// the animation everytime.
/// 
/// So, when the timer corresponding to the question time finished, the 
/// [showQuestionResults] flag is set to true. The new [TimerWidget] is build 
/// with the new result duration time. WHen this timer finished, the 
/// [showQuestionResults] flag is reset to false and the [QuizProvider.nextRound] 
/// method is called to go to the next question.
class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {

  /// false is it's the question time, false if it's the question result time
  bool showQuestionResults = false;
  var timerKey = GlobalKey<_TimerWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(builder: (context, quizProvider, _) {
      final currentQuestion = quizProvider.currentQuestion;
      return GeoQuizLayout(
        body: currentQuestion == null 
          ? ResultsPage()
          : WillPopScope(
            onWillPop: preventMissReturned,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: Dimens.screenMargin,
                    child: TimerWidget(
                      key: timerKey, // to restart the animation when the tree is rebuilt
                      duration: showQuestionResults ? resultDuration : questionDuration,
                      onFinished: showQuestionResults ? nextRound : finishRound,
                      animatedColor: !showQuestionResults,
                      colorSequence: timerColorTweenSequence,
                    ),
                  ),
                ),
                FlexSpacer(),
                Expanded(
                  child: ScrollViewNoEffect(
                    child: QuestionView(
                      question: currentQuestion,
                      showResult: showQuestionResults,
                      onAnswerSelected: (answer) => finishRound(answer: answer),
                      currentNumber: quizProvider.currentNumber,
                      totalNumber: quizProvider.totalNumber,
                      onReady: () => timerKey.currentState.start(),
                    ),
                  ),
                ),
              ],
            ),
          ),
      );
    });
  }

  /// Finish the current round and so to display result
  /// Calls [QuizProvider.updateScore()] and sets state is called to rebuild the
  /// tree (it will start a new timer and show correct and wrong answers)
  finishRound({QuizAnswer answer}) {
    timerKey.currentState.reset();
    bool isCorrect = answer?.isCorrect??false;
    Provider.of<QuizProvider>(context, listen: false).updateScore(isCorrect);
    setState(() => showQuestionResults = true);
  }

  /// End the current question result - time (set [showQuestionResults] to 
  /// false) and ask the provider to provide the next question (if any)
  /// Note: no need to call setState as the provider call will automatically
  /// generate a rebuilt as the [QuizProvider.nextRound()] method notify 
  /// the provider listeners.
  nextRound() {
    timerKey.currentState.reset();
    showQuestionResults = false;
    Provider.of<QuizProvider>(context, listen: false).nextRound();
  }


  ///
  ///
  ///
  Future<bool> preventMissReturned() {
    print("ok");
    var completer = Completer<bool>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Are you sure",
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("NO"), 
            onPressed: () {
              Navigator.pop(context);
              completer.complete(false);
            }
          ),
          FlatButton(
            child: Text("YES"),
            onPressed: () {
              Navigator.pop(context);
              completer.complete(true);
            }
          )
        ],
      )
    );
    return completer.future;
  }
}



/// Used to launch a count-down timer of [duration] and give an UI feedback
///
/// It will launch a timer of [duration] and call the [onFinished] function
/// when the timer reach 0.
/// 
/// The UI feedback is a "progress bar" made with a [Container]. At the 
/// beginning the progress bar take all available width until reach 0px when the
/// timer reaches 0.
/// The background color can be animated or not. To enable the color animation 
/// you need set the [animatedColor] flag to true and to provide a 
/// [colorSequence] that will be used to animate the color. If the timer widget
/// is not animated the default color [ThemeData.colorScheme.surface] will be
/// used.
/// 
/// Note: Make sure to rebuild this widget with a new key if you want to restart
///       a timer when you rebuild the tree
/// 
/// The timer management is deleguate to the [AnimationController] that handle
/// the animation from the [duration] to 0. When the animation ends, the function
/// [onFinished] is called.
/// The animation is started in the initState and disposes in the dispose 
/// method.
class TimerWidget extends StatefulWidget {

  final Duration duration;
  final Function onFinished;
  final bool animatedColor;
  final TweenSequence<Color> colorSequence;

  TimerWidget({
    Key key,
    @required this.duration, 
    @required this.onFinished,
    this.colorSequence,
    this.animatedColor = false,
  }) : assert(animatedColor == false || colorSequence != null),
       super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> with SingleTickerProviderStateMixin {

  AnimationController animController;

  @override
  void initState() {
    super.initState();
    animController = AnimationController(
      vsync: this, 
      duration: widget.duration
    );
  }

  @override
  void dispose() {
    animController.dispose(); // cancel the animation to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: animController,
        builder: (context, _) {
          final screenWidth = constraints.maxWidth;
          final timerWidth = screenWidth- (screenWidth * animController.value);
          return Container(
            width: timerWidth,
            height: 10,
            decoration: BoxDecoration(
              color: evaluateColor(),
              borderRadius: Dimens.roundedBorderRadius
            ),
          );
        }
      ),
    );
  }

  start() {
    animController.forward() // start the animation
      .then((_) { // when the animation ends
        widget.onFinished();
      });
  }

  reset() {
    animController.reset();
  }

  /// Returns the color according to the progress of the animation if the 
  /// animation color is enable.
  /// Returns the default color [Theme.of(context).colorScheme.surface] if
  /// the color animation is disable.
  Color evaluateColor() => widget.animatedColor
    ? widget.colorSequence.evaluate(AlwaysStoppedAnimation(animController.value))
    : Theme.of(context).colorScheme.surface;
}
