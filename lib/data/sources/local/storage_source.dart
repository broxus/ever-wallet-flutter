import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:path_provider/path_provider.dart';

@preResolve
@lazySingleton
class StorageSource {
  late final Storage _storage;

  StorageSource._();

  @factoryMethod
  static Future<StorageSource> create() async {
    final instance = StorageSource._();
    await instance._initialize();
    return instance;
  }

  Storage get storage => _storage;

  Future<void> _initialize() async {
    _storage = await Storage.create(await getApplicationDocumentsDirectory());
  }
}
