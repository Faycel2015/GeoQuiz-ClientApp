import 'package:app/ui/shared/res/dimens.dart';
import 'package:flutter/widgets.dart';


/// Enum used to characterize the type of space used by the [FlexSpacer]
enum _FlexSpacerType {normal, big, small}


/// Empty widget to add space between widgets
/// 
/// Typically used in [Row] or [Column]
/// 
/// ```dart
/// Column(
///   children: <Widget>[
///     Text(...),
///     FlexSpacer.big(),
///     MyWidget(),
///     FlexSpacer(),
///     MyOtherWidget(),
///   ]
/// )
/// ```
class FlexSpacer extends StatelessWidget {

  final _FlexSpacerType spaceType;

  /// Create a normal spacer : [Dimens.normalSpacing]
  FlexSpacer() : spaceType = _FlexSpacerType.normal;

  /// Create a small spacer : [Dimens.smallSpacing]
  FlexSpacer.small() : spaceType = _FlexSpacerType.small;

  /// Create a big spacer : [Dimens.bigSpacing]
  FlexSpacer.big() : spaceType = _FlexSpacerType.big;

  @override
  Widget build(BuildContext context) {
    var space;
    switch (spaceType) {
      case _FlexSpacerType.normal:
        space = Dimens.normalSpacing;
        break;
      case _FlexSpacerType.small:
        space = Dimens.smallSpacing;
        break;
      case _FlexSpacerType.big:
        space = Dimens.bigSpacing;
        break;
    }
    return SizedBox(
      width: space,
      height: space,
    );
  }
}