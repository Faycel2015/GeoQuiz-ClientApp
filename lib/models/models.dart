
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

  QuizTheme theme;
  String entitled;
  ResourceType entitledType;
  List<String> answers;
  ResourceType answersType;
  int difficulty;

  QuizQuestion.fromJSON({@required this.theme, @required Map<String, Object> data}) : super(data["id"]) {
    this.theme = theme;
    this.entitled = data[DatabaseIdentifiers.QUESTION_ENTITLED];
    this.entitledType = ResourceType.fromString(data[DatabaseIdentifiers.QUESTION_ENTITLED_TYPE]);;
    this.answers = (data[DatabaseIdentifiers.QUESTION_ANSWERS] as String).split("&&");
    this.answersType = ResourceType.fromString(data[DatabaseIdentifiers.QUESTION_ANSWERS_TYPE]);
    this.difficulty = data[DatabaseIdentifiers.QUESTION_DIFFICULTY];
  }

  @override
  Map<String, Object> toMap() {
    return {
      DatabaseIdentifiers.QUESTION_ID: id,
      DatabaseIdentifiers.QUESTION_THEME_ID: theme.id,
      DatabaseIdentifiers.QUESTION_ENTITLED: entitled,
      DatabaseIdentifiers.QUESTION_ENTITLED_TYPE: entitledType.value,
      DatabaseIdentifiers.QUESTION_ANSWERS: answers.join("&&"),
      DatabaseIdentifiers.QUESTION_ANSWERS_TYPE: answersType.value,
      DatabaseIdentifiers.QUESTION_DIFFICULTY: difficulty??99,
    };
  }
}


class ResourceType {
  static final ResourceType TEXT = ResourceType._("text");
  static final ResourceType IMAGE = ResourceType._("img");
  static final ResourceType LOCATION = ResourceType._("location");

  final String value;

  ResourceType._(this.value);

  static ResourceType fromString(String s) {
    switch (s) {
      case "text": return TEXT;
      case "img": return IMAGE;
      case "location": return LOCATION;
      default: throw Exception("Unexpected type");
    }
  }

}