import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';


/// Uses instances to log events in the log output
class AppLogger extends Logger {
  AppLogger(String classname) : super(
    filter: null, 
    printer: SimpleLogPrinter(classname), 
    output: null,
  );
}


/// [LogPrinter] extension to format event
// class _AppPrinter extends LogPrinter {
//   @override
//   List<String> log(LogEvent event) {
//     var res = List<String>();
//     res.addAll(event.message.toString().split("\n").map((m) => PrettyPrinter.levelColors[event.level](m)).toList());
//     if (event.error != null)
//       res.addAll(event.error.toString().split("\n").map((m) => PrettyPrinter.levelColors[event.level](m)).toList());
//     return res;
//   }
// }

class SimpleLogPrinter extends LogPrinter {

  final String className;
  SimpleLogPrinter(this.className);  

  @override
  void log(Level level, message, error, StackTrace stackTrace) {
    var color = PrettyPrinter.levelColors[level];
    var emoji = PrettyPrinter.levelEmojis[level];
    var log = '$emoji $className - $message';
    Crashlytics.instance.log(log);
    println(color(log));
    if (level != Level.info) {
      Crashlytics.instance.recordError(error, null);
    }
  }
}