import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'data/dtos/token_contract_asset_dto.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() => $initGetIt(getIt);

@module
abstract class FirebaseModule {
  @preResolve
  @lazySingleton
  Future<FirebaseApp> firebaseApp() async {
    final app = await Firebase.initializeApp();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(kReleaseMode);

    if (kReleaseMode) {
      final flutterOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        FirebaseCrashlytics.instance.recordFlutterError(details);
        if (flutterOnError != null) {
          flutterOnError(details);
        }
      };
    }

    return app;
  }
}

@module
abstract class HiveModule {
  @preResolve
  Future<HiveModule> initHive() async {
    await Hive.initFlutter();

    Hive
      ..registerAdapter(TokenContractAssetDtoAdapter())
      ..registerAdapter(AccountStatusAdapter())
      ..registerAdapter(MessageAdapter())
      ..registerAdapter(TokenIncomingTransferAdapter())
      ..registerAdapter(TokenOutgoingTransferAdapter())
      ..registerAdapter(TokenSwapBackAdapter())
      ..registerAdapter(IncomingTransferAdapter())
      ..registerAdapter(OutgoingTransferAdapter())
      ..registerAdapter(SwapBackAdapter())
      ..registerAdapter(KnownPayloadCommentAdapter())
      ..registerAdapter(KnownPayloadTokenSwapBackAdapter())
      ..registerAdapter(AcceptAdapter())
      ..registerAdapter(TransferBouncedAdapter())
      ..registerAdapter(SwapBackBouncedAdapter())
      ..registerAdapter(TokenWalletTransactionWithDataAdapter())
      ..registerAdapter(TransactionAdapter())
      ..registerAdapter(TransactionIdAdapter())
      ..registerAdapter(OwnerWalletRecipientAdapter())
      ..registerAdapter(TokenWalletRecipientAdapter())
      ..registerAdapter(DePoolOnRoundCompleteNotificationAdapter())
      ..registerAdapter(DePoolReceiveAnswerNotificationAdapter())
      ..registerAdapter(MultisigConfirmTransactionAdapter())
      ..registerAdapter(MultisigSendTransactionAdapter())
      ..registerAdapter(MultisigSubmitTransactionAdapter())
      ..registerAdapter(SendAdapter())
      ..registerAdapter(SubmitAdapter())
      ..registerAdapter(ConfirmAdapter())
      ..registerAdapter(KnownPayloadTokenOutgoingTransferAdapter())
      ..registerAdapter(TokenWalletDeployedNotificationAdapter())
      ..registerAdapter(TonWalletTransactionWithDataAdapter())
      ..registerAdapter(TransactionAdditionalInfoCommentAdapter())
      ..registerAdapter(DePoolOnRoundCompleteAdapter())
      ..registerAdapter(DePoolReceiveAnswerAdapter())
      ..registerAdapter(TokenWalletDeployedAdapter())
      ..registerAdapter(WalletInteractionAdapter())
      ..registerAdapter(WalletInteractionInfoAdapter())
      ..registerAdapter(WalletV3TransferAdapter())
      ..registerAdapter(WalletTypeMultisigAdapter())
      ..registerAdapter(WalletContractTypeAdapter())
      ..registerAdapter(PermissionsAdapter())
      ..registerAdapter(AccountInteractionAdapter())
      ..registerAdapter(TonWalletInfoAdapter())
      ..registerAdapter(TonWalletDetailsAdapter())
      ..registerAdapter(TokenWalletVersionAdapter())
      ..registerAdapter(SymbolAdapter())
      ..registerAdapter(LastTransactionIdAdapter())
      ..registerAdapter(GenTimingsAdapter())
      ..registerAdapter(ContractStateAdapter())
      ..registerAdapter(WalletV3Adapter())
      ..registerAdapter(WalletInteractionMethodMultisigAdapter())
      ..registerAdapter(MultisigTypeAdapter())
      ..registerAdapter(TokenWalletInfoAdapter())
      ..registerAdapter(AssetsListAdapter())
      ..registerAdapter(TonWalletAssetAdapter())
      ..registerAdapter(AdditionalAssetsAdapter())
      ..registerAdapter(TokenWalletAssetAdapter())
      ..registerAdapter(DePoolAssetAdapter());

    return this;
  }
}
