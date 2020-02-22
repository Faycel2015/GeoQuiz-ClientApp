import 'dart:ui';

import 'package:app/models/models.dart';
import 'package:app/ui/pages/quiz/answers.dart';
import 'package:app/ui/shared/assets.dart';
import 'package:app/utils/assets_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';


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
  PictureInfo worldmapDrawable;
  bool mapLoaded = false;
  bool ready = false;

  bool get isResult => widget.onSelected == null;


  @override
  void initState() {
    super.initState();
    loadMap();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (worldmapDrawable == null) {
      return CircularProgressIndicator();
    } else {
      return LayoutBuilder(
        builder: (_, constraints) { 
          double maxWidth = constraints.maxWidth;
          double ratio = worldmapDrawable.size.aspectRatio;
          double height = isResult ?  maxWidth / ratio  : 400;
          double width  = isResult ? maxWidth           : 400 * ratio;
          return SingleChildScrollView(
            physics: !ready ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
            controller: controller,
            scrollDirection: Axis.horizontal,
            child: Stack(
              children:[
                Map(
                  mapDrawable: worldmapDrawable,
                  width: width,
                  height: height,
                ),
                ...widget.answers.map((a) => MapAnswerItem(
                  answer: a,
                  onSelected: isResult ? null : () => widget.onSelected(a),
                  mapWidth: width,
                  mapHeight: height,
                  isSelected: widget.selectedAnswer != null && a == widget.selectedAnswer,
                )),
              ] 
            ),
          );
        }
      );
    }
  }


  loadMap() async {
    this.worldmapDrawable = await AssetsLoader().loadSvg(
      DefaultAssetBundle.of(context), 
      Assets.worldmap,
      Colors.white.withOpacity(0.3),
    );

    setState(() => mapLoaded = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.animateTo(
        controller.position.maxScrollExtent, 
        duration: Duration(milliseconds: 1500), 
        curve: Curves.easeOut,
      );
      checkIfReady();
      controller.addListener(() => checkIfReady());
    });
  }

  checkIfReady() {
    if (controller.offset >= controller.position.maxScrollExtent) {
      setState(() => ready = true);
      widget.onLoaded();
    }
  }
}


class Map extends StatelessWidget {

  final double width;
  final double height;
  final PictureInfo mapDrawable;

  Map({
    @required this.mapDrawable, 
    @required this.width, 
    @required this.height
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: FittedBox(
        fit: BoxFit.fitHeight,
        alignment: Alignment.topCenter,
        child: SizedBox.fromSize(
          size: mapDrawable.viewport.size,
          child: CustomPaint(
            painter: WordlMapPainter(mapDrawable?.picture),
          ),
        ),
      ),
    );
  }
}


class WordlMapPainter extends CustomPainter {
  final Picture svgRoot;

  WordlMapPainter(this.svgRoot);

  @override
  void paint(Canvas canvas, Size size) {    
    if (svgRoot != null) {
      canvas.drawPicture(svgRoot);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}



class MapAnswerItem extends AnswerItem {

  final double mapWidth;
  final double mapHeight;


  MapAnswerItem({
    QuizAnswer answer, 
    void Function() onSelected, 
    bool isSelected = false,
    @required this.mapWidth,
    @required this.mapHeight,
  }) : super(
    answer: answer,
    onSelected: onSelected,
    isSelected: isSelected
  );


  @override
  Widget build(BuildContext context) {
    var position = parseMapPosition();
    return Positioned(
      left: position.x,
      top: position.y,
      child: InkWell(
        onTap: onSelected,
        child: Icon(
          Icons.location_on, 
          color: backColor(context), 
          size: 45, 
        ),
      ),
    );
  }

  _MapPosition parseMapPosition() {
    var xy = answer.answer.resource.split(";");
    var x = double.parse(xy[0]);
    var y = double.parse(xy[1]);
    return _MapPosition(
      mapWidth * x,
      mapHeight * y,
    );
  }
}

class _MapPosition {
  double x;
  double y;

  _MapPosition(this.x, this.y);
}