import 'package:logger/logger.dart';

final logger = CustomLogger();

class CustomLogger {
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: false, printEmojis: false),
  );

  void network(String message) {
    _logger.d('🌐 $message');
  }

  void navigation(String message) {
    _logger.d('🧭 $message');
  }

  void database(String message) {
    _logger.d('📦 $message');
  }

  void debug(String message) {
    _logger.d('🐛 $message');
  }

  void error(String message) {
    _logger.e('❌ $message');
  }
}
