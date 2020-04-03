import 'package:app/src/utils/color_operations.dart';
import 'package:flutter/widgets.dart';


/// Linear gradient background from a single color. Take the whole space
/// 
/// From the given [color] the widget will create a color gradient from a 
/// lighten tint and end with a darken tint.
/// 
/// Lighten and darken color are calculate with the [ColorOperations] class.
/// 
/// It's a very simple widget, no much personnalization.
class GradientBackground extends StatelessWidget {

  final Widget child;
  final Color beginColor;
  final Color endColor;
  final EdgeInsets padding;

  GradientBackground({
    Key key,  
    @required this.child, 
    @required Color color, 
    this.padding
  }) : this.beginColor = ColorOperations.darken(color, 0.05),
       this.endColor = ColorOperations.lighten(color, 0.05),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: double.infinity,
      height: double.infinity,
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