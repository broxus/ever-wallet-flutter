import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';

final logger = FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled
    ? CrashlyticsLogger(printer: prettyPrinter)
    : Logger(printer: prettyPrinter);

final prettyPrinter = PrettyPrinter(
  methodCount: 3,
  errorMethodCount: 6,
  lineLength: 150,
  colors: false,
  printTime: true,
);

class CrashlyticsLogger extends Logger {
  CrashlyticsLogger({
    LogPrinter? printer,
  }) : super(printer: printer);

  @override
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    FirebaseCrashlytics.instance.log(message.toString());
    super.i(
      message,
      error,
      stackTrace,
    );
  }

  @override
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    FirebaseCrashlytics.instance.log(message.toString());
    super.w(
      message,
      error,
      stackTrace,
    );
  }

  @override
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
    );
    super.e(
      message,
      error,
      stackTrace,
    );
  }

  @override
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
    );
    super.wtf(
      message,
      error,
      stackTrace,
    );
  }
}
