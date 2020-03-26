import 'package:app/ui/shared/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class ProgressBar extends StatelessWidget {

  final Color color;
  final int percentage;

  ProgressBar({
    Key key, 
    @required this.percentage,
    @required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (_, constraints) => Stack(
          children: <Widget>[
            Positioned(
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: Dimens.roundedBorderRadius
                ),
                child: SizedBox(
                  width: constraints.maxWidth, 
                  height: 10,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: Dimens.roundedBorderRadius
                ),
                child: SizedBox(
                  width: constraints.maxWidth * ((percentage??0)/100),
                  height: 10,
                ),
              ),
            ),
            Positioned(
              top: 0,right: 0,
              child: Text(
                percentage.toString() + "%",
                style: TextStyle(color: color),
              ),    
            )
          ],
        ),
      ),
    );
  }
}