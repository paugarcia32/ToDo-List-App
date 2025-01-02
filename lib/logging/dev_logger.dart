import 'package:logger/logger.dart';

class DevLogger {
  static final Logger logger = Logger(
    level: Level.debug,
    printer: PrefixPrinter(PrettyPrinter()),
  );
}
