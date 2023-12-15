import 'package:logger/logger.dart';

Logger logger = Logger(
  printer:
      PrettyPrinter(methodCount: 0, noBoxingByDefault: true, colors: false),
);
/* 
var loggerStack = Logger(
  printer: PrettyPrinter(),
);
 */
