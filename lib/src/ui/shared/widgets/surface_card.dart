import 'package:app/src/ui/shared/res/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


/// Card with a box shadow and rouned corner acconrdingly the the app theming
/// 
/// See [Dimens] for more informations about the app theming constants.
/// 
/// We have the following nested widget structure to define the card :
///   Container -> Material -> InkWell -> Container
/// 1. The first Container define the color / border radius;
/// 2. The Material is required to apply to splash effect (transparent);
/// 3. The InkWell to respond on the user tap;
/// 4. The last Widget (here a Container) is the card content with a padding.
/// The InkWell is wrapped inside a Material ancestor as it need it to dispaly
/// a ripple effect (see material theming rules).
/// 
/// See : https://github.com/flutter/flutter/issues/3782 for more information 
class SurfaceCard extends StatelessWidget {

  /// Card content
  final Widget child;

  /// Background color of the card (optionnal)
  final Color color;

  /// Function to called when the user tap on the surface (optionnal)
  final Function onPressed;

  SurfaceCard({
    @required this.child, 
    this.color, 
    this.onPressed
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: Dimens.borderRadius,
        boxShadow: [Dimens.shadow]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          enableFeedback: false, // disable sound effect if any
          borderRadius: Dimens.borderRadius,
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.all(Dimens.surfacePadding),
            child: child
          ),
        ),
      ),
    );
  }
}