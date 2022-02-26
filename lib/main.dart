import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'injection.dart';
import 'logger.dart';
import 'presentation/application/application.dart';

Future<void> main() async {
  try {
    final rawReceivePort = RawReceivePort((pair) async {
      final errorAndStackTrace = pair as List<dynamic>;
      final exception = errorAndStackTrace.first as String;
      final stack = StackTrace.fromString(errorAndStackTrace.last as String);

      logger.e(exception, exception, stack);
    });
    Isolate.current.addErrorListener(rawReceivePort.sendPort);

    loadNekotonLibrary();

    await dotenv.load();

    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    if (Platform.isAndroid) {
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    }

    await configureDependencies();

    setNekotonLogger(logger);

    runZonedGuarded(
      () => runApp(
        const ProviderScope(
          child: Application(),
        ),
      ),
      FirebaseCrashlytics.instance.recordError,
    );
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
