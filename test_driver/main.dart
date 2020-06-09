import 'dart:async';
import 'dart:convert' as c;
import 'dart:ui' as ui;

import 'package:app/main.dart';
import 'package:app/src/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';


class ExampleLocalizations {
  static Future<ExampleLocalizations> load(Locale locale) async {
    final String name = locale.countryCode == null || locale.countryCode.isEmpty
        ? locale.languageCode
        : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return ExampleLocalizations();
  }

  static ExampleLocalizations of(BuildContext context) {
    return Localizations.of<ExampleLocalizations>(
        context, ExampleLocalizations);
  }

  String get title {
    return Intl.message(
      'Screenshots Example',
      name: 'title',
      desc: 'Title for the Example application',
    );
  }

  String get counterText {
    return Intl.message(
      'You have pushed the button this many times:',
      name: 'counterText',
      desc: 'Explanation for incrementing counter',
    );
  }

  String get counterIncrementButtonTooltip {
    return Intl.message(
      'Increment',
      name: 'counterIncrementButtonTooltip',
      desc: 'Tooltip for counter increment button',
    );
  }
}

void main() {
  final DataHandler handler = (_) async {
    final localizations =
        await ExampleLocalizations.load(Locale(ui.window.locale.languageCode));
    final response = {
      'counterIncrementButtonTooltip':
          localizations.counterIncrementButtonTooltip,
      'counterText': localizations.counterText,
      'title': localizations.title,
      'locale': Intl.defaultLocale
    };
    return Future.value(c.jsonEncode(response));
  };
  // Enable integration testing with the Flutter Driver extension.
  // See https://flutter.io/testing/ for more info.
  enableFlutterDriverExtension();
  WidgetsApp.debugAllowBannerOverride = false; // remove debug banner
  Locator.setupLocator();
  runApp(GeoQuizApp());
}