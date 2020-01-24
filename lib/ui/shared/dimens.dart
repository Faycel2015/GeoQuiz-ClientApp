import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class Dimens {
  Dimens._();
  
  static const screenMarginX = 20.0;
  static const screenMarginY = 20.0;
  static const screenMargin = EdgeInsets.symmetric(horizontal: screenMarginX, vertical: screenMarginY);

  static const surfacePadding = 15.0;

  static const radius = 7.0;

  static final shadow = BoxShadow(
    color: Colors.black.withOpacity(0.5), // color of the shadow
    blurRadius: 10, // gaussian attenuation
    spreadRadius: 3 // shadow size
  );

}