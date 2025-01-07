import 'package:logger/logger.dart';

class ProdLogger {
  static final Logger logger = Logger(
    level: Level.fatal,
    printer: PrefixPrinter(
      PrettyPrinter(
        errorMethodCount: 30,
        colors: false,
      ),
    ),
  );
}
