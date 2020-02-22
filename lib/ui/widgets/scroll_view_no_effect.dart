import 'package:flutter/widgets.dart';


/// Define a non-effect scroll behavior (e.g. remove the glow effect on Android)
/// 
/// By default, scrollable widget have a glowing effect. This glow effect comes 
/// from [GlowingOverscrollIndicator] added by [ScrollBehavior]. 
/// This widget remove glow effect.
/// 
/// Use [ScrollConfigarion] widget to define the new scroll behavior with this
/// behvior.
/// 
/// You can used [ScrollViewNoEffect] widget to directly rendered a 
/// [SingleChildScrolView] without scroll effect.
/// 
/// Or, you can used it directly with the [ScrollConfiguration] widget to remove 
/// it on a specific [ListView] for example:
/// ```dart
/// ScrollConfiguration(
///   behavior: BasicScrollWithoutGlow(),
///   child: ListView(
///     ...
///   ),
/// )
/// ```
///
/// Source (stackoverflow): https://stackoverflow.com/a/51119796
class BasicScrollWithoutGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext _, Widget child, AxisDirection __) {
    return child;
  }
}



/// Wraps a [SingleChildScrollView] with attached a non-effect behavior
///
/// Apply the [BasicScrollWithoutGlow] to a [SingleChildScrollView] to remove
/// the glow effect on Android.
class ScrollViewNoEffect extends StatelessWidget {

  final Widget child;
  final ScrollController controller;

  ScrollViewNoEffect({@required this.child, this.controller});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: BasicScrollWithoutGlow(),
      child: SingleChildScrollView(
        child: child,
        controller: controller,
      ),
    );
  }
}