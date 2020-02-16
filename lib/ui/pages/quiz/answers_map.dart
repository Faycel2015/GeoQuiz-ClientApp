
import 'dart:ui';

import 'package:app/models/models.dart';
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
          MapItem(),
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



class MapItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 241,
      child: Icon(Icons.location_on, color: Colors.white, size: 45,),
    );
  }
}