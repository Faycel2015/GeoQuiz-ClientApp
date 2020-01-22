import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class Dimens {
  static final screenMarginX = 20.0;
  static final screenMarginY = 20.0;

  static final radius = 7.0;

  static final shadow = BoxShadow(
    color: Colors.black.withOpacity(0.5), // color of the shadow
    blurRadius: 10, // gaussian attenuation
    spreadRadius: 3 // shadow size
  );

}