import 'package:ever_wallet/application/main/browser/requests/add_asset_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/change_account_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/code_to_tvc_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/decode_event_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/decode_input_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/decode_output_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/decode_transaction_events_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/decode_transaction_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/decrypt_data_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/disconnect_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/encode_internal_input_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/encrypt_data_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/estimate_fees_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/extract_public_key_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_accounts_by_code_hash_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_boc_hash_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_code_salt_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_expected_address_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_full_contract_state_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_provider_state_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_transaction_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_transactions_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/merge_tvc_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/pack_into_cell_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/request_permissions_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/run_local_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/send_external_message_delayed_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/send_external_message_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/send_message_delayed_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/send_message_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/send_unsigned_external_message_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/set_code_salt_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/sign_data_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/sign_data_raw_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/split_tvc_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/subscribe_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/unpack_from_cell_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/unsubscribe_all_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/unsubscribe_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/verify_signature_handler.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Help function to move this huge binding code outside of widget
void browserControllerJavaScriptBind(
  BuildContext context,
  InAppWebViewController controller,
  int tabId,
) {
  controller.addJavaScriptHandler(
    handlerName: 'requestPermissions',
    callback: (args) => requestPermissionsHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      approvalsRepository: context.read<ApprovalsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'changeAccount',
    callback: (args) => changeAccountHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      approvalsRepository: context.read<ApprovalsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'disconnect',
    callback: (args) => disconnectHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      genericContractsRepository: context.read<GenericContractsRepository>(),
      tabId: tabId,
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'subscribe',
    callback: (args) => subscribeHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      genericContractsRepository: context.read<GenericContractsRepository>(),
      tabId: tabId,
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'unsubscribe',
    callback: (args) => unsubscribeHandler(
      controller: controller,
      args: args,
      genericContractsRepository: context.read<GenericContractsRepository>(),
      tabId: tabId,
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'unsubscribeAll',
    callback: (args) => unsubscribeAllHandler(
      controller: controller,
      args: args,
      genericContractsRepository: context.read<GenericContractsRepository>(),
      tabId: tabId,
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'getProviderState',
    callback: (args) => getProviderStateHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      genericContractsRepository: context.read<GenericContractsRepository>(),
      transportRepository: context.read<TransportRepository>(),
      tabId: tabId,
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'getFullContractState',
    callback: (args) => getFullContractStateHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      transportRepository: context.read<TransportRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'getAccountsByCodeHash',
    callback: (args) => getAccountsByCodeHashHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      transportRepository: context.read<TransportRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'getTransactions',
    callback: (args) => getTransactionsHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      transportRepository: context.read<TransportRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'getTransaction',
    callback: (args) => getTransactionHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      transportRepository: context.read<TransportRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'runLocal',
    callback: (args) => runLocalHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      transportRepository: context.read<TransportRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'getExpectedAddress',
    callback: (args) => getExpectedAddressHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'getBocHash',
    callback: (args) => getBocHashHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'packIntoCell',
    callback: (args) => packIntoCellHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'unpackFromCell',
    callback: (args) => unpackFromCellHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'extractPublicKey',
    callback: (args) => extractPublicKeyHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'codeToTvc',
    callback: (args) => codeToTvcHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'mergeTvc',
    callback: (args) => mergeTvcHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'splitTvc',
    callback: (args) => splitTvcHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'setCodeSalt',
    callback: (args) => setCodeSaltHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'getCodeSalt',
    callback: (args) => getCodeSaltHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'encodeInternalInput',
    callback: (args) => encodeInternalInputHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'decodeInput',
    callback: (args) => decodeInputHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'decodeEvent',
    callback: (args) => decodeEventHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'decodeOutput',
    callback: (args) => decodeOutputHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'decodeTransaction',
    callback: (args) => decodeTransactionHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'decodeTransactionEvents',
    callback: (args) => decodeTransactionEventsHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'verifySignature',
    callback: (args) => verifySignatureHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'sendUnsignedExternalMessage',
    callback: (args) => sendUnsignedExternalMessageHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      transportRepository: context.read<TransportRepository>(),
      contractsRepository: context.read<GenericContractsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'addAsset',
    callback: (args) => addAssetHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      approvalsRepository: context.read<ApprovalsRepository>(),
      transportRepository: context.read<TransportRepository>(),
      accountsRepository: context.read<AccountsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'signData',
    callback: (args) => signDataHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      approvalsRepository: context.read<ApprovalsRepository>(),
      keysRepository: context.read<KeysRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'signDataRaw',
    callback: (args) => signDataRawHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      approvalsRepository: context.read<ApprovalsRepository>(),
      keysRepository: context.read<KeysRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'encryptData',
    callback: (args) => encryptDataHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      approvalsRepository: context.read<ApprovalsRepository>(),
      keysRepository: context.read<KeysRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'decryptData',
    callback: (args) => decryptDataHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      approvalsRepository: context.read<ApprovalsRepository>(),
      keysRepository: context.read<KeysRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'estimateFees',
    callback: (args) => estimateFeesHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      tonWalletsRepository: context.read<TonWalletsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'sendMessage',
    callback: (args) => sendMessageHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      approvalsRepository: context.read<ApprovalsRepository>(),
      keysRepository: context.read<KeysRepository>(),
      tonWalletsRepository: context.read<TonWalletsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'sendMessageDelayed',
    callback: (args) => sendMessageDelayedHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      approvalsRepository: context.read<ApprovalsRepository>(),
      keysRepository: context.read<KeysRepository>(),
      tonWalletsRepository: context.read<TonWalletsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'sendExternalMessage',
    callback: (args) => sendExternalMessageHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      approvalsRepository: context.read<ApprovalsRepository>(),
      genericContractsRepository: context.read<GenericContractsRepository>(),
      keysRepository: context.read<KeysRepository>(),
      tonWalletsRepository: context.read<TonWalletsRepository>(),
    ),
  );

  controller.addJavaScriptHandler(
    handlerName: 'sendExternalMessageDelayed',
    callback: (args) => sendExternalMessageDelayedHandler(
      controller: controller,
      args: args,
      permissionsRepository: context.read<PermissionsRepository>(),
      approvalsRepository: context.read<ApprovalsRepository>(),
      keysRepository: context.read<KeysRepository>(),
      genericContractsRepository: context.read<GenericContractsRepository>(),
      tonWalletsRepository: context.read<TonWalletsRepository>(),
    ),
  );
}
