import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

/// Useful constant values share across the app UI 
/// 
/// e.g. padding, font size, font weight, margin, etc.
/// More complex objects are even created as [EdgeInsets], [BoxShadow] and other
/// "styling" flutter properties as it is always the same object configuration
/// used.
/// 
/// Everything is constant, so the constructor is private as it makes no sense 
/// to create an instance of this class.
class Dimens {
  Dimens._();

  static const screenMarginX = 25.0;
  static const screenMarginY = 25.0;
  static const screenMargin = EdgeInsets.symmetric(horizontal: screenMarginX, vertical: screenMarginY);
  static const smallSpacing = 10.0;
  static const normalSpacing = 20.0;
  static const bigSpacing = 30.0;
  static const surfacePadding = 17.0;

  static const radius = 10.0;
  static final borderRadius = BorderRadius.circular(radius);
  static final roundedBorderRadius = BorderRadius.circular(999.0);

  static final shadow = BoxShadow(
    color: Colors.black.withOpacity(0.3), // color of the shadow
    blurRadius: 7, // gaussian attenuation
    spreadRadius: 2 // shadow size
  );

  static final textShadow = BoxShadow(
    color: Colors.black.withOpacity(0.5), // color of the shadow
    blurRadius: 7, // gaussian attenuation
    spreadRadius: 2 // shadow size
  );

}