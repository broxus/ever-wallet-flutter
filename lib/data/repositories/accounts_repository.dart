import 'dart:async';

import 'package:collection/collection.dart';
import 'package:event_bus/event_bus.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/models/account_removed_event.dart';
import 'package:ever_wallet/data/models/key_added_event.dart';
import 'package:ever_wallet/data/models/key_removed_event.dart';
import 'package:ever_wallet/data/models/network_type.dart';
import 'package:ever_wallet/data/sources/local/current_accounts_source.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tuple/tuple.dart';

class AccountsRepository {
  final _lock = Lock();
  final Keystore _keystore;
  final AccountsStorage _accountsStorage;
  final HiveSource _hiveSource;
  final TransportSource _transportSource;
  final CurrentAccountsSource _currentAccountsSource;
  final EventBus _eventBus;
  late final StreamSubscription _currentAccountsStreamSubscription;
  late final StreamSubscription _keyAddedStreamSubscription;
  late final StreamSubscription _keyRemovedStreamSubscription;

  AccountsRepository({
    required Keystore keystore,
    required AccountsStorage accountsStorage,
    required HiveSource hiveSource,
    required TransportSource transportSource,
    required CurrentAccountsSource currentAccountsSource,
    required EventBus eventBus,
  })  : _keystore = keystore,
        _accountsStorage = accountsStorage,
        _hiveSource = hiveSource,
        _transportSource = transportSource,
        _currentAccountsSource = currentAccountsSource,
        _eventBus = eventBus {
    _currentAccountsStreamSubscription = Rx.combineLatest3<String?,
        List<AssetsList>, Map<String, List<String>>, List<AssetsList>>(
      _hiveSource.currentKeyStream,
      accountsStream,
      externalAccountsStream,
      _currentAccountsCombiner,
    ).listen((e) => _currentAccountsSource.currentAccounts = e);

    _keyAddedStreamSubscription = _eventBus
        .on<KeyAddedEvent>()
        .listen((e) => _lock.synchronized(() => _keyAddedStreamListener(e)));

    _keyRemovedStreamSubscription = _eventBus
        .on<KeyRemovedEvent>()
        .listen((e) => _lock.synchronized(() => _keyRemovedStreamListener(e)));
  }

  Stream<List<AssetsList>> get accountsStream => _accountsStorage.entriesStream;

  List<AssetsList> get accounts => _accountsStorage.entries;

  /// Returns stream of the list of external accounts where key - publicKey, value - list of addresses
  Stream<Map<String, List<String>>> get externalAccountsStream =>
      _hiveSource.externalAccountsStream;

  /// Returns stream of the list of addresses of [publicKey]
  Stream<List<String>> externalAccountsForStream(String publicKey) =>
      externalAccountsStream
          .map((accounts) => accounts[publicKey] ?? <String>[]);

  /// Returns the list of external accounts where key - publicKey, value - list of addresses
  Map<String, List<String>> get externalAccounts =>
      _hiveSource.externalAccounts;

  Stream<List<AssetsList>> get currentAccountsStream => Rx.combineLatest2(
        _currentAccountsSource.currentAccountsStream,
        _transportSource.networkTypeStream,
        (a, networkType) {
          return a.where(
            (account) {
              return networkType.when(
                everscale: () =>
                    kEverAvailableWallets.contains(account.tonWallet.contract),
                venom: () =>
                    kVenomAvailableWallets.contains(account.tonWallet.contract),
                tycho: () =>
                    kEverAvailableWallets.contains(account.tonWallet.contract),
              );
            },
          ).toList();
        },
      );

  List<AssetsList> get currentAccounts =>
      _currentAccountsSource.currentAccounts.where(
        (account) {
          return _transportSource.networkType.when(
            everscale: () =>
                kEverAvailableWallets.contains(account.tonWallet.contract),
            venom: () =>
                kVenomAvailableWallets.contains(account.tonWallet.contract),
            tycho: () =>
                kEverAvailableWallets.contains(account.tonWallet.contract),
          );
        },
      ).toList();

  /// Same as [currentAccountsStream] but contains accounts that were not hidden in profile
  Stream<List<AssetsList>> get currentAccountsStreamWithHidden =>
      CombineLatestStream.combine2(
        currentAccountsStream,
        hiddenAccountsStream,
        (accounts, hidden) =>
            List.from(accounts)..removeWhere((a) => hidden.contains(a.address)),
      );

  Stream<Tuple2<List<WalletType>, List<WalletType>>>
      accountCreationOptionsStream(
    String publicKey,
  ) =>
          accountsStream.map(
            (e) => e.toOptionsFor(
              publicKey,
              _transportSource.networkType != NetworkType.venom,
            ),
          );

  Tuple2<List<WalletType>, List<WalletType>> accountCreationOptions(
    String publicKey,
  ) =>
      accounts.toOptionsFor(
        publicKey,
        _transportSource.networkType != NetworkType.venom,
      );

  List<AssetsList> accountsFor(String publicKey) => accounts
      .where(
        (a) =>
            a.publicKey == publicKey ||
            (externalAccounts[publicKey]?.contains(a.address) ?? false),
      )
      .toList();

  Stream<List<AssetsList>> accountsForStream(String publicKey) =>
      Rx.combineLatest2<List<AssetsList>, List<String>, List<AssetsList>>(
        accountsStream,
        externalAccountsForStream(publicKey),
        (accounts, external) => accounts
            .where(
              (a) => a.publicKey == publicKey || (external.contains(a.address)),
            )
            .toList(),
      );

  Stream<List<String>> get hiddenAccountsStream =>
      _hiveSource.hiddenAccountsStream;

  /// If account with [address] is hidden
  Stream<bool> hiddenAccountByAddress(String address) =>
      hiddenAccountsStream.map((hidden) => hidden.contains(address));

  List<String> get hiddenAccounts => _hiveSource.hiddenAccounts;

  Future<void> toggleHiddenAccount(String address) =>
      _hiveSource.toggleHiddenAccount(address);

  Future<AssetsList> addAccount({
    String? name,
    required String publicKey,
    required WalletType walletType,
    required int workchain,
    String? explicitAddress,
  }) =>
      _accountsStorage.addAccount(
        AccountToAdd(
          name: name ??
              walletType.name(
                _transportSource.networkType != NetworkType.venom,
              ),
          publicKey: publicKey,
          contract: walletType,
          workchain: workchain,
          explicitAddress: explicitAddress,
        ),
      );

  Future<AssetsList> addExternalAccount({
    String? name,
    required String publicKey,
    required String address,
  }) async {
    final transport = _transportSource.transport;

    final custodians = await getWalletCustodians(
      transport: transport,
      address: address,
    );

    final isCustodian = custodians.contains(publicKey);

    if (!isCustodian) throw Exception('Is not custodian');

    var account = accounts.firstWhereOrNull((e) => e.address == address);

    if (account == null) {
      final existingWalletInfo = await getExistingWalletInfo(
        transport: transport,
        address: address,
      );

      account = await addAccount(
        name: name,
        publicKey: existingWalletInfo.publicKey,
        walletType: existingWalletInfo.walletType,
        workchain: existingWalletInfo.address.workchain,
        explicitAddress: address,
      );
    }

    await _hiveSource.addExternalAccount(
      publicKey: publicKey,
      address: address,
    );

    return account;
  }

  Future<AssetsList> renameAccount({
    required String address,
    required String name,
  }) =>
      _accountsStorage.renameAccount(
        account: address,
        name: name,
      );

  Future<AssetsList> removeAccount(String address) async {
    final account = accounts.firstWhere((e) => e.address == address);

    final externalAccounts = this
        .externalAccounts
        .entries
        .map(
          (e) => e.value
              .where((e) => e == account.address)
              .map((el) => Tuple2(e.key, el)),
        )
        .expand((e) => e);

    for (final externalAccount in externalAccounts) {
      await removeExternalAccount(
        publicKey: externalAccount.item1,
        address: externalAccount.item2,
      );
    }

    final removedAccount = (await _accountsStorage.removeAccount(address))!;
    await _hiveSource.removeHiddenIfPossible(address);
    await _hiveSource.deletePermissionsForAccount(address);

    _eventBus.fire(AccountRemovedEvent(removedAccount));

    return removedAccount;
  }

  Future<AssetsList?> removeExternalAccount({
    required String publicKey,
    required String address,
  }) async {
    final account = accounts.firstWhere((e) => e.address == address);

    await _hiveSource.removeExternalAccount(
      publicKey: publicKey,
      address: address,
    );

    final isStillExternal =
        externalAccounts.values.expand((e) => e).contains(account.address);
    final isLocal =
        _keystore.entries.map((e) => e.publicKey).contains(account.publicKey);

    if (!isStillExternal && !isLocal) {
      final removedAccount = await removeAccount(account.address);

      return removedAccount;
    } else {
      return null;
    }
  }

  Future<AssetsList> addTokenWallet({
    required String address,
    required String rootTokenContract,
  }) async {
    final transport = _transportSource.transport;

    final account = await _accountsStorage.addTokenWallet(
      account: address,
      rootTokenContract: rootTokenContract,
      networkGroup: transport.group,
    );

    return account;
  }

  Future<AssetsList> removeTokenWallet({
    required String address,
    required String rootTokenContract,
  }) async {
    final transport = _transportSource.transport;

    final account = await _accountsStorage.removeTokenWallet(
      account: address,
      rootTokenContract: rootTokenContract,
      networkGroup: transport.group,
    );

    return account;
  }

  Future<void> clear() async {
    await _accountsStorage.clear();

    await _hiveSource.clearExternalAccounts();
  }

  Future<void> dispose() async {
    await _currentAccountsStreamSubscription.cancel();
    await _keyAddedStreamSubscription.cancel();
    await _keyRemovedStreamSubscription.cancel();
  }

  List<AssetsList> _currentAccountsCombiner(
    String? a,
    List<AssetsList> b,
    Map<String, List<String>> c,
  ) {
    if (a == null) return [];

    final externalAddresses = c[a] ?? [];

    final internalAccounts = b.where((e) => e.publicKey == a);
    final externalAccounts =
        b.where((e) => externalAddresses.contains(e.address));

    final list = [
      ...internalAccounts,
      ...externalAccounts,
    ];

    return list;
  }

  Future<void> _keyAddedStreamListener(KeyAddedEvent event) async {
    try {
      final addedKey = event.key;

      final transport = _transportSource.transport;

      final wallets = await findExistingWallets(
        transport: transport,
        publicKey: addedKey.publicKey,
        workchainId: kDefaultWorkchain,
        walletTypes: _transportSource.networkType != NetworkType.venom
            ? kEverAvailableWallets
            : kVenomAvailableWallets,
      );

      final activeWallets = wallets.where((e) => e.isActive);

      for (final activeWallet in activeWallets) {
        final isExists = accounts.any((e) => e.address == activeWallet.address);

        if (!isExists) {
          await addAccount(
            publicKey: activeWallet.publicKey,
            walletType: activeWallet.walletType,
            workchain: activeWallet.address.workchain,
          );
        }
      }
    } catch (err, st) {
      logger.e('Finding existing wallets error', err, st);
    }
  }

  Future<void> _keyRemovedStreamListener(KeyRemovedEvent event) async {
    try {
      final removedKey = event.key;

      final accounts = this.accounts.where(
            (e) =>
                e.publicKey == removedKey.publicKey &&
                !externalAccounts.values.expand((e) => e).contains(e.address),
          );

      for (final account in accounts) {
        await removeAccount(account.address);
      }
    } catch (err, st) {
      logger.e('Removing unused accounts error', err, st);
    }
  }
}

extension on List<AssetsList> {
  Tuple2<List<WalletType>, List<WalletType>> toOptionsFor(
    String publicKey,
    bool isEver,
  ) {
    final added = where((e) => e.publicKey == publicKey)
        .map((e) => e.tonWallet.contract)
        .toList();
    final available = (isEver ? kEverAvailableWallets : kVenomAvailableWallets)
        .where((e) => !added.contains(e))
        .toList();

    available.sort((a, b) => a.toInt().compareTo(b.toInt()));

    return Tuple2(
      added,
      available,
    );
  }
}

extension on String {
  int get workchain => int.parse(split(':').first);
}
