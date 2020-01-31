import 'package:app/ui/shared/dimens.dart';
import 'package:flutter/widgets.dart';

/// Used to add space margin betwwen elements
/// 
/// Typically used in [Row], [Column] or [ListView].
/// The spacing amout is [Dimens.normalSpacing].
class FelxSpacer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimens.normalSpacing,
      width: Dimens.normalSpacing,
    );
  }
}