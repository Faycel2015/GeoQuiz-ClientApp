import 'package:app/ui/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


/// Defnies the app layout 
/// 
/// It a the following widget tree :
/// 
/// |--- Scaffold
///     |--- GradientBackground
///         |--- SafeArea
///             |--- [body]
/// 
/// The [GradientBackground] is rendered from the [color] property. See the 
/// GradientBackground documentation for more information  about how it is
/// rendered.
/// 
/// The content is wrapped inside a [SafeArea] widget to avoid intrusions by
/// the operating system. In addition, you can define the [bodyPadding]. By 
/// default no padding is applied.
class AppLayout extends StatelessWidget {

  final Widget body;
  final Color color;
  final EdgeInsets bodyPadding;

  AppLayout({
    @required this.body, 
    this.color, 
    this.bodyPadding
  });

  @override
  Widget build(BuildContext context) {
    final backColor = color??Theme.of(context).primaryColor;
    return Scaffold(
      body: GradientBackground(
        padding: bodyPadding,
        color: backColor,
        child: SafeArea(
          child: body
        )
      )
    );
  }
}

