import 'package:app/utils/color_operations.dart';
import 'package:flutter/widgets.dart';

/// Widget to create a linear gradient background from a single color.
/// 
/// The gradient will simply begins with a lighten tint and end with a 
/// darken tint of the color given as parameters.
/// 
/// It's a very simple widget, no much personnalization.
class GradientBackground extends StatelessWidget {

  final Widget child;
  final Color beginColor;
  final Color endColor;
  final EdgeInsets padding;

  GradientBackground({Key key, @required this.child, @required Color color, this.padding}) 
  : this.beginColor = ColorOperations.darken(color, 0.05),
    this.endColor = ColorOperations.lighten(color, 0.05),
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [beginColor, endColor]
        )
      ),
      child: child
    );
  }
}