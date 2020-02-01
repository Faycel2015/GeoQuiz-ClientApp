import 'package:app/ui/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GeoQuizLayout extends StatelessWidget {

  final Widget body;
  final Color color;
  final EdgeInsets bodyPadding;

  GeoQuizLayout({@required this.body, this.color, this.bodyPadding});

  @override
  Widget build(BuildContext context) {
    final backColor = color??Theme.of(context).primaryColor;
    return Scaffold(
      body: GradientBackground(
        padding: bodyPadding,
        color: backColor,
        child: SafeArea(
          child: body
        )
      )
    );
  }
}