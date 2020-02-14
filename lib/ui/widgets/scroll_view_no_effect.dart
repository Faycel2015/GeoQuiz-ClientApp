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
/// To remove the glow on the whole application, you can add it right under the
/// root tree.
/// 
/// To remove it on a specific ListView, instead wrap only the desired ListView.
/// 
/// ```dart
/// ScrollConfiguration(
///   behavior: BasicScrollWithoutGlow(),
///   child: ListView(
///     ...
///   ),
/// )
/// ```
///
/// Source: https://stackoverflow.com/a/51119796
class BasicScrollWithoutGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}



class ScrollViewNoEffect extends StatelessWidget {

  final Widget child;

  ScrollViewNoEffect({@required this.child});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: BasicScrollWithoutGlow(),
      child: SingleChildScrollView(
        child: child,
      ),
    );
  }

}