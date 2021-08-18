import 'dart:async';
import 'dart:isolate';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'injection.dart';
import 'logger.dart';
import 'presentation/application/application.dart';

Future<void> main() async {
  await dotenv.load();

  EasyLocalization.logger.enableBuildModes = [];
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await configureDependencies();

  final rawReceivePort = RawReceivePort((pair) async {
    final errorAndStackTrace = pair as List<dynamic>;
    final exception = errorAndStackTrace.first as String;
    final stack = StackTrace.fromString(errorAndStackTrace.last as String);

    logger.e(exception, exception, stack);
  });

  Isolate.current.addErrorListener(rawReceivePort.sendPort);

  runZonedGuarded(
    () => runApp(Application()),
    FirebaseCrashlytics.instance.recordError,
  );
}
