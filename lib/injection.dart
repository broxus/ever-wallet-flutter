import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'data/dtos/account_status_dto.dart';
import 'data/dtos/de_pool_on_round_complete_notification_dto.dart';
import 'data/dtos/de_pool_receive_answer_notification_dto.dart';
import 'data/dtos/eth_event_status_dto.dart';
import 'data/dtos/known_payload_dto.dart';
import 'data/dtos/message_dto.dart';
import 'data/dtos/multisig_confirm_transaction_dto.dart';
import 'data/dtos/multisig_send_transaction_dto.dart';
import 'data/dtos/multisig_submit_transaction_dto.dart';
import 'data/dtos/multisig_transaction_dto.dart';
import 'data/dtos/token_contract_asset_dto.dart';
import 'data/dtos/token_incoming_transfer_dto.dart';
import 'data/dtos/token_outgoing_transfer_dto.dart';
import 'data/dtos/token_swap_back_dto.dart';
import 'data/dtos/token_wallet_deployed_notification_dto.dart';
import 'data/dtos/token_wallet_transaction_dto.dart';
import 'data/dtos/token_wallet_transaction_with_data_dto.dart';
import 'data/dtos/ton_event_status_dto.dart';
import 'data/dtos/ton_wallet_transaction_with_data_dto.dart';
import 'data/dtos/transaction_additional_info_dto.dart';
import 'data/dtos/transaction_dto.dart';
import 'data/dtos/transaction_id_dto.dart';
import 'data/dtos/transfer_recipient_dto.dart';
import 'data/dtos/wallet_interaction_info_dto.dart';
import 'data/dtos/wallet_interaction_method_dto.dart' as wim;
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
      ..registerAdapter(AccountStatusDtoAdapter())
      ..registerAdapter(MessageDtoAdapter())
      ..registerAdapter(TokenIncomingTransferDtoAdapter())
      ..registerAdapter(TokenOutgoingTransferDtoAdapter())
      ..registerAdapter(TokenSwapBackDtoAdapter())
      ..registerAdapter(IncomingTransferDtoAdapter())
      ..registerAdapter(OutgoingTransferDtoAdapter())
      ..registerAdapter(SwapBackDtoAdapter())
      ..registerAdapter(AcceptDtoAdapter())
      ..registerAdapter(TransferBouncedDtoAdapter())
      ..registerAdapter(SwapBackBouncedDtoAdapter())
      ..registerAdapter(TokenWalletTransactionWithDataDtoAdapter())
      ..registerAdapter(TransactionDtoAdapter())
      ..registerAdapter(TransactionIdDtoAdapter())
      ..registerAdapter(OwnerWalletRecipientDtoAdapter())
      ..registerAdapter(TokenWalletRecipientDtoAdapter())
      ..registerAdapter(DePoolOnRoundCompleteNotificationDtoAdapter())
      ..registerAdapter(DePoolReceiveAnswerNotificationDtoAdapter())
      ..registerAdapter(EthEventStatusDtoAdapter())
      ..registerAdapter(CommentAdapter())
      ..registerAdapter(TokenOutgoingTransferAdapter())
      ..registerAdapter(TokenSwapBackAdapter())
      ..registerAdapter(MultisigConfirmTransactionDtoAdapter())
      ..registerAdapter(MultisigSendTransactionDtoAdapter())
      ..registerAdapter(MultisigSubmitTransactionDtoAdapter())
      ..registerAdapter(SendAdapter())
      ..registerAdapter(SubmitAdapter())
      ..registerAdapter(ConfirmAdapter())
      ..registerAdapter(TokenWalletDeployedNotificationDtoAdapter())
      ..registerAdapter(TonEventStatusDtoAdapter())
      ..registerAdapter(TonWalletTransactionWithDataDtoAdapter())
      ..registerAdapter(CommentDtoAdapter())
      ..registerAdapter(DePoolOnRoundCompleteDtoAdapter())
      ..registerAdapter(DePoolReceiveAnswerDtoAdapter())
      ..registerAdapter(TokenWalletDeployedDtoAdapter())
      ..registerAdapter(EthEventStatusChangedDtoAdapter())
      ..registerAdapter(TonEventStatusChangedDtoAdapter())
      ..registerAdapter(WalletInteractionDtoAdapter())
      ..registerAdapter(WalletInteractionInfoDtoAdapter())
      ..registerAdapter(wim.WalletV3TransferAdapter())
      ..registerAdapter(wim.MultisigAdapter())
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
      ..registerAdapter(MultisigAdapter())
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
