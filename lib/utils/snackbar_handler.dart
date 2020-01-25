import 'package:app/ui/shared/dimens.dart';
import 'package:flutter/material.dart';



class SnackBarHandler {
  static showSnackbar({BuildContext context, Widget content, bool critical = false}) {
    final _colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = critical ? _colorScheme.error : _colorScheme.primaryVariant;
    final textColor = critical ? _colorScheme.onError : _colorScheme.onPrimary;
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: DefaultTextStyle(
          style: TextStyle(color: textColor),
          child: content
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: Dimens.borderRadius),
        action: SnackBarAction(
          label: "Ok", 
          textColor: textColor,
          onPressed: Scaffold.of(context).removeCurrentSnackBar,
        ),
      )
    );
  }
}