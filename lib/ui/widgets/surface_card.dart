import 'package:app/ui/shared/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SurfaceCard extends StatelessWidget {

  final Widget child;
  final Color color;
  final Function onPressed;

  SurfaceCard({@required this.child, this.color, this.onPressed});
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(Dimens.surfacePadding),
        decoration: BoxDecoration(
          color: color,
          borderRadius: Dimens.borderRadius,
          boxShadow: [Dimens.shadow]
        ),
        child: child
      ),
    );
  }
}