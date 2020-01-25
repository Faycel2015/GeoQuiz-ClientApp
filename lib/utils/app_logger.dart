import 'package:logger/logger.dart';


class AppLogger extends Logger {
  AppLogger() : super(
    filter: null, 
    printer: AppPrinter(), 
    output: null,
  );
}


class AppPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    var res = List<String>();
    res.addAll(event.message.toString().split("\n").map((m) => PrettyPrinter.levelColors[event.level](m)).toList());
    if (event.error != null)
      res.addAll(event.error.toString().split("\n").map((m) => PrettyPrinter.levelColors[event.level](m)).toList());
    return res;
  }
}
