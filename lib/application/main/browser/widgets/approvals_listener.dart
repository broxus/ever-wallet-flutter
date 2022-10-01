import 'dart:async';

import 'package:ever_wallet/application/main/browser/add_tip3_token_modal/show_add_tip3_token_modal.dart';
import 'package:ever_wallet/application/main/browser/call_contract_method_modal/show_call_contract_method_modal.dart';
import 'package:ever_wallet/application/main/browser/change_account_modal/show_change_account_modal.dart';
import 'package:ever_wallet/application/main/browser/decrypt_data/show_decrypt_data_modal.dart';
import 'package:ever_wallet/application/main/browser/encrypt_data/show_encrypt_data_modal.dart';
import 'package:ever_wallet/application/main/browser/request_permissions_modal/show_request_permissions_modal.dart';
import 'package:ever_wallet/application/main/browser/send_message_modal/show_send_message_modal.dart';
import 'package:ever_wallet/application/main/browser/show_add_account_dialog.dart';
import 'package:ever_wallet/application/main/browser/sign_data/show_sign_data_modal.dart';
import 'package:ever_wallet/application/main/common/get_local_custodians_public_keys.dart';
import 'package:ever_wallet/data/models/permission.dart';
import 'package:ever_wallet/data/models/permissions.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

class ApprovalsListener extends StatefulWidget {
  final Widget child;

  const ApprovalsListener({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ApprovalsListener> createState() => _ApprovalsListenerState();
}

class _ApprovalsListenerState extends State<ApprovalsListener> {
  late final StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription = context.read<ApprovalsRepository>().approvalsStream.listen(
          (event) => event.when(
            requestPermissions: (
              origin,
              permissions,
              completer,
            ) =>
                requestPermissions(
              context: context,
              origin: origin,
              permissions: permissions,
              completer: completer,
            ),
            changeAccount: (
              origin,
              permissions,
              completer,
            ) =>
                changeAccount(
              context: context,
              origin: origin,
              permissions: permissions,
              completer: completer,
            ),
            addTip3Token: (
              origin,
              account,
              details,
              completer,
            ) =>
                addTip3Token(
              context: context,
              origin: origin,
              account: account,
              details: details,
              completer: completer,
            ),
            signData: (
              origin,
              publicKey,
              data,
              completer,
            ) =>
                signData(
              context: context,
              origin: origin,
              publicKey: publicKey,
              data: data,
              completer: completer,
            ),
            encryptData: (
              origin,
              publicKey,
              data,
              completer,
            ) =>
                encryptData(
              context: context,
              origin: origin,
              publicKey: publicKey,
              data: data,
              completer: completer,
            ),
            decryptData: (
              origin,
              publicKey,
              sourcePublicKey,
              completer,
            ) =>
                decryptData(
              context: context,
              origin: origin,
              publicKey: publicKey,
              sourcePublicKey: sourcePublicKey,
              completer: completer,
            ),
            callContractMethod: (
              origin,
              publicKey,
              recipient,
              payload,
              completer,
            ) =>
                callContractMethod(
              context: context,
              origin: origin,
              publicKey: publicKey,
              recipient: recipient,
              payload: payload,
              completer: completer,
            ),
            sendMessage: (
              origin,
              sender,
              recipient,
              amount,
              bounce,
              payload,
              knownPayload,
              completer,
            ) =>
                sendMessage(
              context: context,
              origin: origin,
              sender: sender,
              recipient: recipient,
              amount: amount,
              bounce: bounce,
              payload: payload,
              knownPayload: knownPayload,
              completer: completer,
            ),
          ),
        );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Future<void> requestPermissions({
    required BuildContext context,
    required String origin,
    required List<Permission> permissions,
    required Completer<Permissions> completer,
  }) async {
    try {
      final accounts = context.read<AccountsRepository>().currentAccounts;

      if (accounts.isEmpty) {
        final currentKey = context.read<KeysRepository>().currentKey;

        if (!mounted) return;
        if (currentKey == null) throw Exception(AppLocalizations.of(context)!.no_current_key);

        showAddAccountDialog(
          context: context,
          publicKey: currentKey.publicKey,
        );

        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.no_accounts);
      }

      final result = await showRequestPermissionsModal(
        context: context,
        origin: origin,
        permissions: permissions,
      );

      if (result != null) {
        completer.complete(result);
      } else {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.not_granted);
      }
    } catch (err, st) {
      completer.completeError(err, st);
    }
  }

  Future<void> changeAccount({
    required BuildContext context,
    required String origin,
    required List<Permission> permissions,
    required Completer<Permissions> completer,
  }) async {
    try {
      final accounts = context.read<AccountsRepository>().currentAccounts;

      if (accounts.isEmpty) {
        final currentKey = context.read<KeysRepository>().currentKey;

        if (!mounted) return;
        if (currentKey == null) throw Exception(AppLocalizations.of(context)!.no_current_key);

        showAddAccountDialog(
          context: context,
          publicKey: currentKey.publicKey,
        );

        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.no_accounts);
      }

      final result = await showChangeAccountModal(
        context: context,
        permissions: permissions,
        origin: origin,
      );

      if (result != null) {
        completer.complete(result);
      } else {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.not_granted);
      }
    } catch (err, st) {
      completer.completeError(err, st);
    }
  }

  Future<void> addTip3Token({
    required BuildContext context,
    required String origin,
    required String account,
    required RootTokenContractDetails details,
    required Completer<void> completer,
  }) async {
    try {
      final result = await showAddTip3TokenModal(
        context: context,
        origin: origin,
        account: account,
        details: details,
      );

      if (result == true) {
        completer.complete();
      } else {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.not_granted);
      }
    } catch (err, st) {
      completer.completeError(err, st);
    }
  }

  Future<void> signData({
    required BuildContext context,
    required String origin,
    required String publicKey,
    required String data,
    required Completer<String> completer,
  }) async {
    try {
      final result = await showSignDataModal(
        context: context,
        origin: origin,
        publicKey: publicKey,
        data: data,
      );

      if (result != null) {
        completer.complete(result);
      } else {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.no_password);
      }
    } catch (err, st) {
      completer.completeError(err, st);
    }
  }

  Future<void> encryptData({
    required BuildContext context,
    required String origin,
    required String publicKey,
    required String data,
    required Completer<String> completer,
  }) async {
    try {
      final result = await showEncryptDataModal(
        context: context,
        origin: origin,
        publicKey: publicKey,
        data: data,
      );

      if (result != null) {
        completer.complete(result);
      } else {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.no_password);
      }
    } catch (err, st) {
      completer.completeError(err, st);
    }
  }

  Future<void> decryptData({
    required BuildContext context,
    required String origin,
    required String publicKey,
    required String sourcePublicKey,
    required Completer<String> completer,
  }) async {
    try {
      final result = await showDecryptDataModal(
        context: context,
        origin: origin,
        publicKey: publicKey,
        sourcePublicKey: sourcePublicKey,
      );

      if (result != null) {
        completer.complete(result);
      } else {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.no_password);
      }
    } catch (err, st) {
      completer.completeError(err, st);
    }
  }

  Future<void> callContractMethod({
    required BuildContext context,
    required String origin,
    required String publicKey,
    required String recipient,
    required FunctionCall payload,
    required Completer<String> completer,
  }) async {
    try {
      final result = await showCallContractMethodModal(
        context: context,
        origin: origin,
        publicKey: publicKey,
        recipient: recipient,
        payload: payload,
      );

      if (result != null) {
        completer.complete(result);
      } else {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.no_password);
      }
    } catch (err, st) {
      completer.completeError(err, st);
    }
  }

  Future<void> sendMessage({
    required BuildContext context,
    required String origin,
    required String sender,
    required String recipient,
    required String amount,
    required bool bounce,
    required FunctionCall? payload,
    required KnownPayload? knownPayload,
    required Completer<Tuple2<String, String>> completer,
  }) async {
    try {
      final publicKeys = await getLocalCustodiansPublicKeys(
        context: context,
        address: sender,
      );

      final result = await showSendMessageModal(
        context: context,
        origin: origin,
        sender: sender,
        publicKeys: publicKeys,
        recipient: recipient,
        amount: amount,
        bounce: bounce,
        payload: payload,
        knownPayload: knownPayload,
      );

      if (result != null) {
        completer.complete(result);
      } else {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.no_password);
      }
    } catch (err, st) {
      completer.completeError(err, st);
    }
  }
}
