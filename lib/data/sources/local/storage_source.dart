import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

@preResolve
@lazySingleton
class StorageSource {
  late final Storage storage;

  StorageSource._();

  @factoryMethod
  static Future<StorageSource> create() async {
    final instance = StorageSource._();
    await instance._initialize();
    return instance;
  }

  Future<void> _initialize() async {
    storage = await Storage.create();
  }
}
