import 'package:app/src/locator.dart';
import 'package:app/src/models/models.dart';
import 'package:app/src/services/local_database_service.dart';
import 'package:app/src/ui/quiz/other/quiz_error_page.dart';
import 'package:app/src/ui/quiz/other/quiz_loading_page.dart';
import 'package:app/src/ui/quiz/question/question_page.dart';
import 'package:app/src/ui/quiz/quiz_provider.dart';
import 'package:app/src/ui/quiz/result/results_page.dart';
import 'package:app/src/ui/shared/res/values.dart';
import 'package:app/src/ui/shared/widgets/geoquiz_layout.dart';
import 'package:app/src/ui/shared/widgets/will_pop_scope_warning.dart';
import 'package:app/src/ui/themes/themes_provider.dart';
import 'package:flutter/material.dart';
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
/// If there is an available question the [QuestionPage] with a [TimerWidget]
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
  ///
  QuizPage({
    Key key,
    @required this.quizConfig,
  }) : assert(quizConfig != null, "quizConfig cannot be null"),
       super(key: key);

  ///
  static const routeName = "/quiz";
  
  ///
  final QuizConfig quizConfig;

  @override
  _QuizPageState createState() => _QuizPageState();


}

class _QuizPageState extends State<QuizPage> {
  /// false is it's the question time, false if it's the question result time
  bool showQuestionResults = false;

  ///
  var questionKey = GlobalKey();

  ///
  QuizProvider quizProvider;

  @override
  initState() {
    super.initState();
    quizProvider = QuizProvider(
      config: widget.quizConfig,
      localDbService: Locator.of<ILocalDatabaseRepository>()
    )..prepareGame();
  }

  /// Finish the current round and so to display result
  /// Calls [QuizProvider.updateScore()] and sets state is called to rebuild the
  /// tree (it will start a new timer and show correct and wrong answers)
  terminateRound({QuizQuestion question, QuizAnswer answer}) {
    bool isCorrect = answer?.isCorrect??false;
    if (isCorrect)
      quizProvider.addCorrectlyAnsweredQuestion(question);
    setState(() => showQuestionResults = true);
  }

  /// End the current question result - time (set [showQuestionResults] to 
  /// false) and ask the provider to provide the next question (if any)
  /// Note: no need to call setState as the provider call will automatically
  /// generate a rebuilt as the [QuizProvider.nextRound()] method notify 
  /// the provider listeners.
  nextRound() {
    questionKey = GlobalKey();
    showQuestionResults = false;
    bool hasNext = quizProvider.nextRound();
    if (!hasNext) {
      var correctQuestions = quizProvider.correctlyAnsweredQuestion;
      Locator.of<ThemesProvider>().updateProgressions(correctQuestions);
    }
  }

  Widget _getBody(QuizProvider quizProvider) {
    switch (quizProvider.state) {
      case QuizState.busy:
        return FetchingQuestionsInProgress();
      
      case QuizState.inProgress:
        final currentQuestion = quizProvider.currentQuestion;
        return WillPopScopeWarning(
          child:QuestionPage(
            key: questionKey,
            question: currentQuestion,
            currentNumber: quizProvider.currentQuestionNumber,
            totalNumber: quizProvider.totalQuestionNumber,
            showResult: showQuestionResults,
            onFinished: (answer) => !showQuestionResults ?
              terminateRound(question: currentQuestion, answer: answer)
              : nextRound()
          )
        );
      
      case QuizState.finished:
        return ResultsPage();
      
      case QuizState.idle:
      case QuizState.error:
      default:
        return FetchingQuestionsError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuizProvider>.value(
      value: quizProvider,
      child: Consumer<QuizProvider>(
        builder: (context, quizProvider, _) => AppLayout(
          body: _getBody(quizProvider)
        )
      ),
    );
  }
}