import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

import '../../logger.dart';
import '../constants.dart';
import '../sources/local/nekoton_source.dart';
import 'keystore_repository.dart';
import 'transport_repository.dart';

@preResolve
@lazySingleton
class AccountsStorageRepository {
  late final AccountsStorage _accountsStorage;
  final NekotonSource _nekotonSource;
  final KeystoreRepository _keystoreRepository;
  final TransportRepository _transportRepository;
  final _accountsSubject = BehaviorSubject<List<AssetsList>>.seeded([]);

  AccountsStorageRepository._(
    this._nekotonSource,
    this._keystoreRepository,
    this._transportRepository,
  );

  @factoryMethod
  static Future<AccountsStorageRepository> create({
    required NekotonSource nekotonSource,
    required KeystoreRepository keystoreRepository,
    required TransportRepository transportRepository,
  }) async {
    final accountsStorageRepository = AccountsStorageRepository._(
      nekotonSource,
      keystoreRepository,
      transportRepository,
    );
    await accountsStorageRepository._initialize();
    return accountsStorageRepository;
  }

  Stream<List<AssetsList>> get accountsStream => _accountsSubject.stream;

  List<AssetsList> get accounts => _accountsSubject.value;

  Future<AssetsList> addAccount({
    required String name,
    required String publicKey,
    required WalletType walletType,
    required int workchain,
  }) async {
    final account = await _accountsStorage.addAccount(
      name: name,
      publicKey: publicKey,
      walletType: walletType,
      workchain: workchain,
    );

    _accountsSubject.add(await _accountsStorage.accounts);

    return account;
  }

  Future<AssetsList> renameAccount({
    required String address,
    required String name,
  }) async {
    final account = await _accountsStorage.renameAccount(
      address: address,
      name: name,
    );

    _accountsSubject.add(await _accountsStorage.accounts);

    return account;
  }

  Future<AssetsList?> removeAccount(String address) async {
    final account = await _accountsStorage.removeAccount(address);

    _accountsSubject.add(await _accountsStorage.accounts);

    return account;
  }

  Future<AssetsList> addTokenWallet({
    required String address,
    required String rootTokenContract,
  }) async {
    final transport = _transportRepository.transport;

    final tokenWallet = await TokenWallet.subscribe(
      transport: transport,
      owner: address,
      rootTokenContract: rootTokenContract,
    );

    await tokenWallet.freePtr();

    final account = await _accountsStorage.addTokenWallet(
      address: address,
      rootTokenContract: rootTokenContract,
      networkGroup: transport.connectionData.group,
    );

    _accountsSubject.add(await _accountsStorage.accounts);

    return account;
  }

  Future<AssetsList> removeTokenWallet({
    required String address,
    required String rootTokenContract,
  }) async {
    final transport = _transportRepository.transport;

    final account = await _accountsStorage.removeTokenWallet(
      address: address,
      rootTokenContract: rootTokenContract,
      networkGroup: transport.connectionData.group,
    );

    _accountsSubject.add(await _accountsStorage.accounts);

    return account;
  }

  Future<void> clear() async {
    await _accountsStorage.clear();

    _accountsSubject.add(await _accountsStorage.accounts);
  }

  Future<void> _initialize() async {
    _accountsStorage = await AccountsStorage.create(_nekotonSource.storage);

    _accountsSubject.add(await _accountsStorage.accounts);

    final lock = Lock();
    _keystoreRepository.keysStream
        .skip(1)
        .startWith(_keystoreRepository.keys)
        .pairwise()
        .listen((e) => lock.synchronized(() => _keysStreamListener(e)));
  }

  Future<void> _keysStreamListener(Iterable<List<KeyStoreEntry>> event) async {
    try {
      final prev = event.first;
      final next = event.last;

      final addedKeys = [...next]..removeWhere((e) => prev.any((el) => el.publicKey == e.publicKey));
      final removedKeys = [...prev]..removeWhere((e) => next.any((el) => el.publicKey == e.publicKey));

      for (final key in addedKeys) {
        final wallets = await findExistingWallets(
          transport: _transportRepository.transport,
          publicKey: key.publicKey,
          workchainId: kDefaultWorkchain,
        );

        final activeWallets =
            wallets.where((e) => e.contractState.isDeployed || BigInt.parse(e.contractState.balance) > BigInt.zero);

        for (final activeWallet in activeWallets) {
          final isExists = accounts.any((e) => e.address == activeWallet.address);

          if (!isExists) {
            await addAccount(
              name: activeWallet.walletType.describe(),
              publicKey: key.publicKey,
              walletType: activeWallet.walletType,
              workchain: kDefaultWorkchain,
            );
          }
        }
      }

      for (final key in removedKeys) {
        final removedAccounts = accounts.where((e) => e.publicKey == key.publicKey);

        for (final removedAccount in removedAccounts) {
          await removeAccount(removedAccount.address);
        }
      }
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
