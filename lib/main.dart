import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'injection.dart';
import 'logger.dart';
import 'presentation/application.dart';

void main(List<String> args) {
  runZonedGuarded<Future<void>>(
    () async {
      Isolate.current.addErrorListener(
        RawReceivePort((dynamic pair) async {
          final list = pair as List<dynamic>;
          final err = list.first as String;
          final st = StackTrace.fromString(list.last as String);

          logger.e('Current isolate error', err, st);
        }).sendPort,
      );

      FlutterError.onError = (FlutterErrorDetails details) => logger.e(
            details.library,
            details.exception,
            details.stack,
          );

      await dotenv.load();

      NekotonFlutter.initialize(logger);

      WidgetsFlutterBinding.ensureInitialized();

      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

      await configureDependencies();

      runApp(const Application());
    },
    (err, st) => logger.e('Zoned error', err, st),
  );
}
