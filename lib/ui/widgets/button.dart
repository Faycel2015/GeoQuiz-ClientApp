import 'package:app/utils/color_operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


/// Rounded button with no elevation and respects the app theming
///
/// The default background color is [ThemeData.colorScheme.secondary]. So, the
/// front color ([icon] and [label]) is the corresponding onSecondary.
/// If the flag [light] is set to true, then the background color is the
/// primaryVariant and the text color is onPrimary.
/// 
/// It wraps the label inside a [Flexible] widget to all multiple line
/// text label.
/// 
/// ```dart
/// Button(
///   onPressed: () {
///     /*...*/
///   },
///   label: "My label",
///   icon: /*...*/
/// )
/// ```
class Button extends StatelessWidget {
  final Widget icon;
  final String label;
  final Function onPressed;
  final bool light;

  Button({
    @required this.icon, 
    @required this.label, 
    @required this.onPressed,
    this.light = false
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backColor = light ? colorScheme.primaryVariant : colorScheme.secondary;
    final frontColor = light ? colorScheme.onPrimary : colorScheme.onSecondary;
    return FlatButton.icon(
      icon: icon, 
      label: Flexible(child: Text(label)),
      color: backColor,
      disabledColor: ColorOperations.darken(backColor, 0.15),
      textColor: frontColor,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      shape: StadiumBorder(),
      onPressed: onPressed, 
    );
  }
}