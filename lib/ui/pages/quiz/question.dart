import 'dart:io';
import 'dart:ui';

import 'package:app/models/models.dart';
import 'package:app/ui/shared/assets.dart';
import 'package:app/ui/shared/dimens.dart';
import 'package:app/ui/widgets/flex_spacer.dart';
import 'package:app/ui/widgets/surface_card.dart';
import 'package:app/utils/assets_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:app/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';


/// No need to randomize
/// No need to limit question lenght
class QuestionView extends StatefulWidget {

  final QuizQuestion question;
  final bool showResult;
  final Function(QuizAnswer) onAnswerSelected;
  final int totalNumber;
  final int currentNumber;
  final Function onReady;


  QuestionView({
    @required this.question, 
    @required this.currentNumber,
    @required this.totalNumber,
    this.onAnswerSelected, 
    this.onReady,
    this.showResult = false,
  });

  @override
  _QuestionViewState createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {

  QuizAnswer selectedAnswer;
  bool get ready => _questionEntitledLoaded && _answersLoaded;

  bool _questionEntitledLoaded = false;
  bool _answersLoaded = false;


  @override
  Widget build(BuildContext context) {
    return  Column(
        children: <Widget>[
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
              this._questionEntitledLoaded = true;
              if (ready) widget.onReady();
            }
          ),
          FlexSpacer(big: true,),
          Answers(
            key: GlobalKey(),
            answers: widget.question.answers,
            onSelected: widget.showResult ? null : onSelectedAnswer,
            selectedAnswer: selectedAnswer,
            onCompletelyRendered: () {
              this._answersLoaded = true;
              if (ready) widget.onReady();
            }
          )
        ],
    );
  }

  onSelectedAnswer(answer) {
    setState(() => selectedAnswer = answer);
    widget.onAnswerSelected(answer);
  }
}




class ThemeEntitled extends StatelessWidget {
  
  final QuizTheme theme;

  ThemeEntitled({@required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(theme.entitled, style: TextStyle(fontSize: 25));
  }
}



class QuestionEntitled extends StatelessWidget {
    
  final Resource entitled;
  final Function onCompletelyRendered;


  QuestionEntitled({@required this.entitled, @required this.onCompletelyRendered});

  @override
  Widget build(BuildContext context) {
    onCompletelyRendered();
    switch (entitled.type) {
      case ResourceType.image:
        return buildImage(context);
        break;
      case ResourceType.text:
      default:
        return buildText(context);
    }
  }

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
}


class Answers extends StatelessWidget {
  final List<QuizAnswer> answers;
  final Function(QuizAnswer) onSelected;
  final QuizAnswer selectedAnswer;
  final Function onCompletelyRendered;

  Answers({
    Key key, 
    @required this.answers, 
    this.onSelected, 
    this.selectedAnswer,
    @required this.onCompletelyRendered
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMap = answers.first.answer.type == ResourceType.location;
    isMap = true;
    if (isMap) {
      return AnswersMap(
        key: GlobalKey(),
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



class AnswersMap extends StatefulWidget {

  final List<QuizAnswer> answers;
  final Function(QuizAnswer) onSelected;
  final QuizAnswer selectedAnswer;
  final Function onLoaded;

  AnswersMap({
    Key key,
    @required this.answers,
    this.onSelected,
    this.selectedAnswer,
    @required this.onLoaded
  }) : super(key: key);

  @override
  _AnswersMapState createState() => _AnswersMapState();
}

class _AnswersMapState extends State<AnswersMap> with SingleTickerProviderStateMixin {
 
  ScrollController controller = ScrollController();
  int offset = 0;
  PictureInfo worldmapDrawable;
  Size worlmapSize = Size(1,1);


  @override
  void initState() {
    super.initState();
    loadMap();

  }


  @override
  Widget build(BuildContext context) {
    final viewportSize = worldmapDrawable?.viewport?.size??Size(1,1);
    final Rect viewport = Offset.zero & viewportSize;
    return SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      child: Stack(
        children:[
          SizedBox(
            height: worlmapSize.height,
            width: worlmapSize.width,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              alignment: Alignment.topCenter,
              child: SizedBox.fromSize(
                size: viewport.size,
                child: CustomPaint(
                  painter: WordlMapPainter(worldmapDrawable?.picture, worlmapSize),
                ),
              ),
            ),
          ),
          Positioned(
            left: 241,
            child: Icon(Icons.location_on, color: Colors.white, size: 45,),
          )
        ] 
      ),
    );
  }


  loadMap() async {
    this.worldmapDrawable = await AssetsLoader().loadSvg(
      DefaultAssetBundle.of(context), 
      Assets.worldmap,
      Colors.white.withOpacity(0.3),
    );
    final ratio = worldmapDrawable.size.aspectRatio;
    this.worlmapSize = Size(400*ratio,400);

    setState(() {});
    widget.onLoaded();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      controller.animateTo(
        controller.position.maxScrollExtent, 
        duration: Duration(seconds: 3), 
        curve: Curves.easeOut,
      )
    );
  }

}


class WordlMapPainter extends CustomPainter {
  final Picture svgRoot;
  final Size size;

  WordlMapPainter(this.svgRoot, this.size);

  @override
  void paint(Canvas canvas, Size size) {    
    if (svgRoot != null) {
      canvas.drawPicture(svgRoot);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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


class QuestionNumber extends StatelessWidget {
  final int current;
  final int max;

  QuestionNumber({@required this.current, @required this.max});

  @override
  Widget build(BuildContext context) {
    return Text("$current / $max");
  }
}