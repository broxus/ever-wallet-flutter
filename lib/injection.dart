import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import 'data/dtos/token_contract_asset_dto.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => $initGetIt(getIt);

@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAnalytics get firebaseAnalytics => FirebaseAnalytics();

  @preResolve
  @lazySingleton
  Future<FirebaseApp> firebaseApp(FirebaseAnalytics analytics) async {
    final app = await Firebase.initializeApp();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(kReleaseMode);

    if (kReleaseMode) {
      final flutterOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        FirebaseCrashlytics.instance.recordFlutterError(details);
        if (flutterOnError != null) {
          flutterOnError(details);
        }
      };
    }

    return app;
  }
}

@module
abstract class HiveModule {
  @preResolve
  Future<HiveModule> initHive() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TokenContractAssetDtoAdapter());

    return this;
  }
}
