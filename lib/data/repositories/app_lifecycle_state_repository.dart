import 'dart:ui';

import 'package:ever_wallet/data/sources/local/app_lifecycle_state_source.dart';

class AppLifecycleStateRepository {
  final AppLifecycleStateSource _appLifecycleStateSource;

  AppLifecycleStateRepository(this._appLifecycleStateSource);

  AppLifecycleState updateAppLifecycleState(AppLifecycleState appLifecycleState) =>
      _appLifecycleStateSource.appLifecycleState;
}
