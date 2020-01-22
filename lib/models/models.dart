
import 'package:app/utils/database_identifiers.dart';
import 'package:flutter/widgets.dart';

abstract class Model {
  String id;

  Model(this.id);

  Map<String, Object> toMap();
}


class QuizTheme extends Model {

  String title;
  String entitled;
  String icon;
  int color;

  QuizTheme.fromJSON({@required Map<String, Object> data}) : super(data[DatabaseIdentifiers.THEME_ID]) {
    this.title = data[DatabaseIdentifiers.THEME_TITLE];
    this.icon = data[DatabaseIdentifiers.THEME_ICON];
    this.color = data[DatabaseIdentifiers.THEME_COLOR] as int;
    this.entitled = data[DatabaseIdentifiers.THEME_ENTITLED];
  }

  @override
  Map<String, Object> toMap() {
    return {
      DatabaseIdentifiers.THEME_ID: id,
      DatabaseIdentifiers.THEME_TITLE: title,
      DatabaseIdentifiers.THEME_ICON: icon,
      DatabaseIdentifiers.THEME_COLOR: color,
      DatabaseIdentifiers.THEME_ENTITLED: entitled,
    };
  }
}


class QuizQuestion extends Model {

  QuizQuestion.fromJSON({@required Map<String, Object> data}) : super(data["id"]) {

  }

  @override
  Map<String, Object> toMap() {
    return {};
  }

}