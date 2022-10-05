import 'dart:async';
import 'dart:ui';

import 'package:rxdart/rxdart.dart';

class AppLifecycleStateSource {
  final _appLifecycleStateSubject =
      BehaviorSubject<AppLifecycleState>.seeded(AppLifecycleState.resumed);

  Stream<AppLifecycleState> get appLifecycleStateStream => _appLifecycleStateSubject;

  AppLifecycleState get appLifecycleState => _appLifecycleStateSubject.value;

  set appLifecycleState(AppLifecycleState appLifecycleState) =>
      _appLifecycleStateSubject.add(appLifecycleState);

  Future<void> dispose() => _appLifecycleStateSubject.close();
}
