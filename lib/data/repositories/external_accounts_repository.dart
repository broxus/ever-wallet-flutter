import 'dart:async';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

import '../../logger.dart';
import '../sources/local/hive_source.dart';
import 'accounts_storage_repository.dart';
import 'keystore_repository.dart';
import 'transport_repository.dart';

@preResolve
@lazySingleton
class ExternalAccountsRepository {
  final HiveSource _hiveSource;
  final TransportRepository _transportRepository;
  final AccountsStorageRepository _accountsStorageRepository;
  final KeystoreRepository _keystoreRepository;
  final _externalAccountsSubject = BehaviorSubject<Map<String, List<String>>>.seeded({});

  ExternalAccountsRepository._(
    this._hiveSource,
    this._transportRepository,
    this._accountsStorageRepository,
    this._keystoreRepository,
  );

  @factoryMethod
  static Future<ExternalAccountsRepository> create({
    required HiveSource hiveSource,
    required TransportRepository transportRepository,
    required AccountsStorageRepository accountsStorageRepository,
    required KeystoreRepository keystoreRepository,
  }) async {
    final externalAccountsRepository = ExternalAccountsRepository._(
      hiveSource,
      transportRepository,
      accountsStorageRepository,
      keystoreRepository,
    );
    await externalAccountsRepository._initialize();
    return externalAccountsRepository;
  }

  Stream<Map<String, List<String>>> get externalAccountsStream => _externalAccountsSubject.stream;

  Map<String, List<String>> get externalAccounts => _externalAccountsSubject.value;

  Future<void> addExternalAccount({
    required String publicKey,
    required String address,
    String? name,
  }) async {
    final transport = _transportRepository.transport;

    final tonWallet = await TonWallet.subscribeByAddress(
      transport: transport,
      address: address,
    );

    final custodians = await tonWallet.custodians ?? [];

    if (!custodians.contains(publicKey)) {
      throw Exception('Is not custodian');
    }

    final isExists = _accountsStorageRepository.accounts.any((e) => e.address == address);

    if (!isExists) {
      await _accountsStorageRepository.addAccount(
        name: name ?? tonWallet.walletType.describe(),
        publicKey: tonWallet.publicKey,
        walletType: tonWallet.walletType,
        workchain: tonWallet.workchain,
      );
    } else if (name != null) {
      await _accountsStorageRepository.renameAccount(
        address: address,
        name: name,
      );
    }

    await _hiveSource.addExternalAccount(
      publicKey: publicKey,
      address: address,
    );

    _externalAccountsSubject.add(_hiveSource.getExternalAccounts());

    await tonWallet.freePtr();
  }

  Future<void> removeExternalAccount({
    required String publicKey,
    required String address,
  }) async {
    await _hiveSource.removeExternalAccount(
      publicKey: publicKey,
      address: address,
    );

    _externalAccountsSubject.add(_hiveSource.getExternalAccounts());

    final account = _accountsStorageRepository.accounts.firstWhereOrNull((e) => e.address == address);

    if (account != null) {
      final transport = _transportRepository.transport;

      final tonWallet = await TonWallet.subscribeByAddress(
        transport: transport,
        address: address,
      );

      final custodians = await tonWallet.custodians ?? [];

      final keys = _keystoreRepository.keys.map((e) => e.publicKey);

      final isExists = keys.any((e) => custodians.any((el) => el == e));

      if (!isExists) {
        await _accountsStorageRepository.removeAccount(account.address);
      }

      await tonWallet.freePtr();
    }
  }

  Future<void> clear() async {
    await _hiveSource.clearExternalAccounts();

    _externalAccountsSubject.add(_hiveSource.getExternalAccounts());
  }

  Future<void> _initialize() async {
    _externalAccountsSubject.add(_hiveSource.getExternalAccounts());

    final lock = Lock();
    _accountsStorageRepository.accountsStream
        .skip(1)
        .startWith(_accountsStorageRepository.accounts)
        .pairwise()
        .listen((e) => lock.synchronized(() => _accountsStreamListener(e)));
  }

  Future<void> _accountsStreamListener(Iterable<List<AssetsList>> event) async {
    try {
      final prev = event.first;
      final next = event.last;

      final removedAccounts = [...prev]..removeWhere((e) => next.any((el) => el.address == e.address));

      for (final account in removedAccounts) {
        final removedExternalAccounts = externalAccounts.entries
            .map((e) => e.value.map((el) => Tuple2(e.key, el)))
            .expand((e) => e)
            .where((e) => e.item2 == account.address);

        for (final removedExternalAccount in removedExternalAccounts) {
          await removeExternalAccount(
            publicKey: removedExternalAccount.item1,
            address: removedExternalAccount.item2,
          );
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
