import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

@preResolve
@lazySingleton
class NekotonSource {
  late final Storage storage;

  NekotonSource._();

  @factoryMethod
  static Future<NekotonSource> create() async {
    final nekotonSource = NekotonSource._();
    await nekotonSource._initialize();
    return nekotonSource;
  }

  Future<void> _initialize() async {
    storage = await Storage.create();
  }
}
