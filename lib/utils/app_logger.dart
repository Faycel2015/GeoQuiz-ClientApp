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
    return event.message.toString().split("\n").map((m) => PrettyPrinter.levelColors[event.level](m)).toList();
  }


}
