import 'package:app/ui/shared/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


/// Card with a box shadow and rouned corner
/// 
/// NOTE:
/// It's a little tricky to show a card with a custom box shadow as we 
/// have to use [InkWell] and [Container] widget but the InWell widget splash 
/// only on [Material] widget (it's a the material theming rule), we need to 
/// have the following widgets nesting widget structure : 
///   Container -> Material -> InkWell -> Container
/// 1. The first Container define the color / border radius;
/// 2. The Material is required to apply to splash effect (transparent);
/// 3. The InkWell to respond on the user tap;
/// 4. The last Widget (here a Container) is the card content with a padding.
/// 
/// See : https://github.com/flutter/flutter/issues/3782 for more information 
class SurfaceCard extends StatelessWidget {

  /// Card content
  final Widget child;

  /// Background color (optionnal)
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