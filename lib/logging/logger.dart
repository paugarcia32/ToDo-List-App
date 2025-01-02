import 'package:logger/logger.dart' as logger show Logger;
import 'package:logger/logger.dart';

class Logger {
  static logger.Logger log = logger.Logger(
    printer: PrettyPrinter(
      errorMethodCount: 3,
      lineLength: 50,
    ),
  );
}
