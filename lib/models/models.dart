
import 'package:flutter/widgets.dart';

abstract class Model {
  String id;

  Model(this.id);

  Map<String, Object> toMap();
}

class QuizTheme extends Model {

  String title;

  QuizTheme.fromJSON({@required Map<String, Object> data}) : super(data["id"]) {
    this.title = data["title"];
  }

  @override
  Map<String, Object> toMap() {
    return null;
  }

}

class QuizQuestion extends Model {

  QuizQuestion.fromJSON({@required Map<String, Object> data}) : super(data["id"]) {

  }

  @override
  Map<String, Object> toMap() {
    return null;
  }

}