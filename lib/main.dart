import 'dart:async';
import 'dart:ui';

import 'package:ever_wallet/application/application.dart';
import 'package:ever_wallet/application/error_splash_screen.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logger.e('FlutterError', details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.e('PlatformDispatcher', error, stack);
    return true;
  };

  FlutterError.onError = (FlutterErrorDetails details) => logger.e(
        details.library,
        details.exception,
        details.stack,
      );
  ErrorWidget.builder = (details) => ErrorSplashScreen(text: details.exception.toString());

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const Application());
}
