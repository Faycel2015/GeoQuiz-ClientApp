import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

/// Useful constants destined to be used by the UI widgets 
/// 
/// e.g. padding, font size, font weight, margin, etc.
/// 
/// More complex objects are also created as [EdgeInsets], [BoxShadow] and other
/// "styling" properties.
/// 
/// Everything is constant, so the constructor is private as it makes no sense 
/// to create an instance of this class.
class Dimens {

  Dimens._();

  static const double screenMarginX = 25.0;
  static const double screenMarginY = screenMarginX;
  static const EdgeInsets screenMargin = EdgeInsets.symmetric(
    horizontal: screenMarginX, 
    vertical: screenMarginY
  );

  static const double smallSpacing = 10.0;
  static const double normalSpacing = 20.0;
  static const double bigSpacing = 30.0;

  static const double surfacePadding = 17.0;

  static const double radius = 10.0;
  static final BorderRadius borderRadius = BorderRadius.circular(radius);
  static final BorderRadius roundedBorderRadius = BorderRadius.circular(999);

  static final BoxShadow shadow = BoxShadow(
    color: Colors.black.withOpacity(0.3), // color of the shadow
    blurRadius: 7, // gaussian attenuation
    spreadRadius: 2 // shadow size
  );
  static final BoxShadow textShadow = BoxShadow(
    color: Colors.black.withOpacity(0.5), // color of the shadow
    blurRadius: 7, // gaussian attenuation
    spreadRadius: 2 // shadow size
  );

  static final double menuIconSize = 34;
}