import 'dart:async';

import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/error_splash_screen.dart';
import 'package:ever_wallet/application/loading_splash_screen.dart';
import 'package:ever_wallet/application/main/main_screen.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:ever_wallet/data/repositories/bookmarks_repository.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/locale_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/search_history_repository.dart';
import 'package:ever_wallet/data/repositories/sites_meta_data_repository.dart';
import 'package:ever_wallet/data/repositories/token_currencies_repository.dart';
import 'package:ever_wallet/data/repositories/token_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/ton_assets_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/data/sources/local/current_accounts_source.dart';
import 'package:ever_wallet/data/sources/local/current_key_source.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/data/sources/local/ledger_source.dart';
import 'package:ever_wallet/data/sources/remote/http_source.dart';
import 'package:ever_wallet/data/sources/remote/transport_source.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';

class ApplicationInjection extends StatelessWidget {
  final Widget child;

  const ApplicationInjection({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => hiveSourceProvider(
        child: MultiProvider(
          providers: [
            storageProvider(),
            ledgerSourceProvider(),
            ledgerConnectionProvider(),
          ],
          builder: (context, child) => keystoreProvider(
            child: accountsStorageProvider(
              child: MultiProvider(
                providers: [
                  currentAccountsSourceProvider(),
                  currentKeySourceProvider(),
                  httpSourceProvider(),
                  transportSourceProvider(),
                  approvalsRepositoryProvider(),
                  genericContractsRepositoryProvider(),
                  localeRepositoryProvider(),
                  permissionsRepositoryProvider(),
                  sitesMetaDataRepositoryProvider(),
                  tokenCurrenciesRepositoryProvider(),
                  tokenWalletsRepositoryProvider(),
                  tonWalletsRepositoryProvider(),
                  accountsRepositoryProvider(),
                  bookmarksRepositoryProvider(),
                  searchHistoryRepositoryProvider(),
                  tonAssetsRepositoryProvider(),
                  transportRepositoryProvider(),
                  navigatorKeyProvider(),
                  mainNavigatorKeyProvider(),
                ],
                builder: (context, child) => biometryRepositoryProvider(
                  child: keysRepositoryProvider(
                    child: this.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget hiveSourceProvider({
    required Widget child,
  }) =>
      asyncValueProvider<HiveSource>(
        create: (context) => HiveSource.create(),
        dispose: (context, value) => value.dispose(),
        child: child,
      );

  Provider<Storage> storageProvider() => Provider<Storage>(
        create: (context) {
          final hiveSource = context.read<HiveSource>();

          return Storage(
            get: (key) => hiveSource.getStorageData(key),
            set: ({
              required key,
              required value,
            }) =>
                hiveSource.setStorageData(key: key, value: value),
            setUnchecked: ({
              required key,
              required value,
            }) =>
                hiveSource.setStorageData(key: key, value: value),
            remove: (key) => hiveSource.removeStorageData(key),
            removeUnchecked: (key) => hiveSource.removeStorageData(key),
          );
        },
        dispose: (context, value) => value.dispose(),
      );

  Provider<LedgerSource> ledgerSourceProvider() => Provider(create: (context) => LedgerSource());

  Provider<LedgerConnection> ledgerConnectionProvider() => Provider<LedgerConnection>(
        create: (context) {
          final ledgerSource = context.read<LedgerSource>();

          return LedgerConnection(
            getPublicKey: (accountId) => ledgerSource.getPublicKey(accountId),
            sign: ({
              required account,
              required message,
              context,
            }) =>
                ledgerSource.sign(account: account, message: message),
          );
        },
        dispose: (context, value) => value.dispose(),
      );

  Widget keystoreProvider({
    required Widget child,
  }) =>
      asyncValueProvider<Keystore>(
        create: (context) {
          final storage = context.read<Storage>();
          final ledgerConnection = context.read<LedgerConnection>();

          return Keystore.create(
            storage: storage,
            ledgerConnection: ledgerConnection,
            signers: [
              kEncryptedKeySignerName,
              kDerivedKeySignerName,
              kLedgerKeySignerName,
            ],
          );
        },
        dispose: (context, value) => value.dispose(),
        child: child,
      );

  Widget accountsStorageProvider({
    required Widget child,
  }) =>
      asyncValueProvider<AccountsStorage>(
        create: (context) => AccountsStorage.create(context.read<Storage>()),
        dispose: (context, value) => value.dispose(),
        child: child,
      );

  Provider<CurrentAccountsSource> currentAccountsSourceProvider() =>
      Provider<CurrentAccountsSource>(
        create: (context) => CurrentAccountsSource(),
        dispose: (context, value) => value.dispose(),
      );

  Provider<CurrentKeySource> currentKeySourceProvider() => Provider<CurrentKeySource>(
        create: (context) => CurrentKeySource(),
        dispose: (context, value) => value.dispose(),
      );

  Provider<HttpSource> httpSourceProvider() => Provider<HttpSource>(
        create: (context) => HttpSource(),
      );

  Provider<TransportSource> transportSourceProvider() => Provider<TransportSource>(
        create: (context) => TransportSource(context.read<HttpSource>()),
        dispose: (context, value) => value.dispose(),
      );

  Provider<ApprovalsRepository> approvalsRepositoryProvider() => Provider<ApprovalsRepository>(
        create: (context) => ApprovalsRepository(),
        dispose: (context, value) => value.dispose(),
      );

  Provider<GenericContractsRepository> genericContractsRepositoryProvider() =>
      Provider<GenericContractsRepository>(
        create: (context) => GenericContractsRepository(context.read<TransportSource>()),
        dispose: (context, value) => value.dispose(),
      );

  Provider<LocaleRepository> localeRepositoryProvider() => Provider<LocaleRepository>(
        create: (context) => LocaleRepository(context.read<HiveSource>()),
        dispose: (context, value) => value.dispose(),
      );

  Provider<PermissionsRepository> permissionsRepositoryProvider() =>
      Provider<PermissionsRepository>(
        create: (context) => PermissionsRepository(
          context.read<AccountsStorage>(),
          context.read<HiveSource>(),
        ),
        dispose: (context, value) => value.dispose(),
      );

  Provider<SitesMetaDataRepository> sitesMetaDataRepositoryProvider() =>
      Provider<SitesMetaDataRepository>(
        create: (context) => SitesMetaDataRepository(context.read<HiveSource>()),
      );

  Provider<TokenCurrenciesRepository> tokenCurrenciesRepositoryProvider() =>
      Provider<TokenCurrenciesRepository>(
        create: (context) => TokenCurrenciesRepository(
          context.read<CurrentAccountsSource>(),
          context.read<HiveSource>(),
          context.read<HttpSource>(),
        ),
        dispose: (context, value) => value.dispose(),
      );

  Provider<TokenWalletsRepository> tokenWalletsRepositoryProvider() =>
      Provider<TokenWalletsRepository>(
        create: (context) => TokenWalletsRepository(
          context.read<AccountsStorage>(),
          context.read<CurrentAccountsSource>(),
          context.read<TransportSource>(),
          context.read<HiveSource>(),
        ),
        dispose: (context, value) => value.dispose(),
      );

  Provider<TonWalletsRepository> tonWalletsRepositoryProvider() => Provider<TonWalletsRepository>(
        create: (context) => TonWalletsRepository(
          context.read<AccountsStorage>(),
          context.read<CurrentAccountsSource>(),
          context.read<TransportSource>(),
          context.read<HiveSource>(),
        ),
        dispose: (context, value) => value.dispose(),
      );

  Provider<AccountsRepository> accountsRepositoryProvider() => Provider<AccountsRepository>(
        create: (context) => AccountsRepository(
          context.read<AccountsStorage>(),
          context.read<CurrentAccountsSource>(),
          context.read<TransportSource>(),
          context.read<Keystore>(),
          context.read<CurrentKeySource>(),
          context.read<HiveSource>(),
        ),
        dispose: (context, value) => value.dispose(),
      );

  Provider<BookmarksRepository> bookmarksRepositoryProvider() => Provider<BookmarksRepository>(
        create: (context) => BookmarksRepository(context.read<HiveSource>()),
        dispose: (context, value) => value.dispose(),
      );

  Provider<SearchHistoryRepository> searchHistoryRepositoryProvider() =>
      Provider<SearchHistoryRepository>(
        create: (context) => SearchHistoryRepository(context.read<HiveSource>()),
        dispose: (context, value) => value.dispose(),
      );

  Provider<TonAssetsRepository> tonAssetsRepositoryProvider() => Provider<TonAssetsRepository>(
        create: (context) => TonAssetsRepository(
          context.read<AccountsStorage>(),
          context.read<TransportSource>(),
          context.read<HiveSource>(),
          context.read<HttpSource>(),
        ),
        dispose: (context, value) => value.dispose(),
      );

  Provider<TransportRepository> transportRepositoryProvider() => Provider<TransportRepository>(
        create: (context) => TransportRepository(
          context.read<TransportSource>(),
          context.read<HiveSource>(),
        ),
      );

  Widget biometryRepositoryProvider({
    required Widget child,
  }) =>
      asyncValueProvider<BiometryRepository>(
        create: (context) => BiometryRepository.create(context.read<HiveSource>()),
        dispose: (context, value) => value.dispose(),
        child: child,
      );

  Widget keysRepositoryProvider({
    required Widget child,
  }) =>
      asyncValueProvider<KeysRepository>(
        create: (context) => KeysRepository.create(
          keystore: context.read<Keystore>(),
          currentKeySource: context.read<CurrentKeySource>(),
          hiveSource: context.read<HiveSource>(),
        ),
        dispose: (context, value) => value.dispose(),
        child: child,
      );

  Widget asyncValueProvider<T>({
    required Future<T> Function(BuildContext context) create,
    required void Function(BuildContext context, T value)? dispose,
    required Widget child,
  }) =>
      FutureProvider<AsyncValue<T>>(
        create: (context) => create(context).then((value) => AsyncValue.ready(value)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, _) => context.watch<AsyncValue<T>>().when(
              ready: (value) => Provider<T>(
                create: (context) => value,
                dispose: dispose,
                child: child,
              ),
              error: (error) => ErrorSplashScreen(text: '$error'),
              loading: () => const LoadingSplashScreen(),
            ),
      );

  Provider navigatorKeyProvider() => Provider<GlobalKey<NavigatorState>>(
        create: (context) => GlobalKey(),
      );

  Provider mainNavigatorKeyProvider() => Provider<GlobalKey<MainScreenState>>(
    create: (context) => GlobalKey(),
  );
}
