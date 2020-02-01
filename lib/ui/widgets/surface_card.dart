import 'package:app/ui/shared/dimens.dart';
import 'package:flutter/widgets.dart';

class SurfaceCard extends StatelessWidget {

  final Widget child;
  final Color color;

  SurfaceCard({@required this.child, this.color});
  
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(Dimens.surfacePadding),
        decoration: BoxDecoration(
          color: color,
          borderRadius: Dimens.borderRadius,
          boxShadow: [Dimens.shadow]
        ),
        child: child
    );
  }
}