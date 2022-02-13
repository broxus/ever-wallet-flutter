import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import 'accounts_storage_repository.dart';
import 'current_key_repository.dart';
import 'external_accounts_repository.dart';

@preResolve
@lazySingleton
class CurrentAccountsRepository {
  final CurrentKeyRepository _currentKeyRepository;
  final AccountsStorageRepository _accountsStorageRepository;
  final ExternalAccountsRepository _externalAccountsRepository;
  final _currentAccountsSubject = BehaviorSubject<List<AssetsList>>.seeded([]);

  CurrentAccountsRepository._(
    this._currentKeyRepository,
    this._accountsStorageRepository,
    this._externalAccountsRepository,
  );

  @factoryMethod
  static Future<CurrentAccountsRepository> create({
    required CurrentKeyRepository currentKeyRepository,
    required AccountsStorageRepository accountsStorageRepository,
    required ExternalAccountsRepository externalAccountsRepository,
  }) async {
    final currentAccountsRepository = CurrentAccountsRepository._(
      currentKeyRepository,
      accountsStorageRepository,
      externalAccountsRepository,
    );
    await currentAccountsRepository._initialize();
    return currentAccountsRepository;
  }

  Stream<List<AssetsList>> get currentAccountsStream => _currentAccountsSubject.stream;

  List<AssetsList> get currentAccounts => _currentAccountsSubject.value;

  Future<void> _initialize() async {
    Rx.combineLatest3<KeyStoreEntry?, List<AssetsList>, Map<String, List<String>>, List<AssetsList>>(
      _currentKeyRepository.currentKeyStream,
      _accountsStorageRepository.accountsStream,
      _externalAccountsRepository.externalAccountsStream,
      (a, b, c) {
        Iterable<AssetsList> internalAccounts = [];
        Iterable<AssetsList> externalAccounts = [];

        if (a != null) {
          final externalAddresses = c[a.publicKey] ?? [];

          internalAccounts = b.where((e) => e.publicKey == a.publicKey);
          externalAccounts =
              b.where((e) => e.publicKey != a.publicKey && externalAddresses.any((el) => el == e.address));
        }

        final list = [
          ...internalAccounts,
          ...externalAccounts,
        ]..sort();

        return list;
      },
    ).listen((e) => _currentAccountsSubject.add(e));
  }
}
