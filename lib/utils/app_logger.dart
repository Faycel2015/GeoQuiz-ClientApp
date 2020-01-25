import 'package:logger/logger.dart';


/// Uses instances to log events in the log output
class AppLogger extends Logger {
  AppLogger() : super(
    filter: null, 
    printer: _AppPrinter(), 
    output: null,
  );
}


/// [LogPrinter] extension to format event
class _AppPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    var res = List<String>();
    res.addAll(event.message.toString().split("\n").map((m) => PrettyPrinter.levelColors[event.level](m)).toList());
    if (event.error != null)
      res.addAll(event.error.toString().split("\n").map((m) => PrettyPrinter.levelColors[event.level](m)).toList());
    return res;
  }
}
