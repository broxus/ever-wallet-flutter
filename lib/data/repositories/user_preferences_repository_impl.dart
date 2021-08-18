import 'package:injectable/injectable.dart';

import '../../domain/repositories/user_preferences_repository.dart';
import '../sources/local/hive_source.dart';

@LazySingleton(as: UserPreferencesRepository)
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final HiveSource _hiveSource;

  UserPreferencesRepositoryImpl(this._hiveSource);

  @override
  Future<String?> get currentPublicKey async => _hiveSource.currentPublicKey;

  @override
  Future<void> setCurrentPublicKey(String? currentPublicKey) async => _hiveSource.setCurrentPublicKey(currentPublicKey);

  @override
  Future<void> clear() async => _hiveSource.clearUserPreferences();
}
