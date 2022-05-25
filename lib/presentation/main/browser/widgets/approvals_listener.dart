import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../data/models/approval_request.dart';
import '../../../../../../providers/common/approvals_provider.dart';
import '../../../../data/models/permission.dart';
import '../../../../data/models/permissions.dart';
import '../../../../data/repositories/accounts_repository.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../../generated/codegen_loader.g.dart';
import '../../../../injection.dart';
import '../../common/get_local_custodians_public_keys.dart';
import '../add_tip3_token_modal/show_add_tip3_token_modal.dart';
import '../call_contract_method_modal/show_call_contract_method_modal.dart';
import '../change_account_modal/show_change_account_modal.dart';
import '../decrypt_data/show_decrypt_data_modal.dart';
import '../encrypt_data/show_encrypt_data_modal.dart';
import '../request_permissions_modal/show_request_permissions_modal.dart';
import '../send_message_modal/show_send_message_modal.dart';
import '../show_add_account_dialog.dart';
import '../sign_data/show_sign_data_modal.dart';

class ApprovalsListener extends StatelessWidget {
  final Widget child;

  const ApprovalsListener({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue<ApprovalRequest>>(
            approvalsProvider,
            (previous, next) => next.whenData(
              (value) => value.when(
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
            ),
          );

          return child!;
        },
        child: child,
      );

  Future<void> requestPermissions({
    required BuildContext context,
    required String origin,
    required List<Permission> permissions,
    required Completer<Permissions> completer,
  }) async {
    try {
      final accounts = getIt.get<AccountsRepository>().currentAccounts;

      if (accounts.isEmpty) {
        final currentKey = getIt.get<KeysRepository>().currentKey;

        if (currentKey == null) throw Exception(LocaleKeys.no_current_key.tr());

        showAddAccountDialog(
          context: context,
          publicKey: currentKey.publicKey,
        );

        throw Exception(LocaleKeys.no_accounts.tr());
      }

      final result = await showRequestPermissionsModal(
        context: context,
        origin: origin,
        permissions: permissions,
      );

      if (result != null) {
        completer.complete(result);
      } else {
        throw Exception(LocaleKeys.not_granted.tr());
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
      final accounts = getIt.get<AccountsRepository>().currentAccounts;

      if (accounts.isEmpty) {
        final currentKey = getIt.get<KeysRepository>().currentKey;

        if (currentKey == null) throw Exception(LocaleKeys.no_current_key.tr());

        showAddAccountDialog(
          context: context,
          publicKey: currentKey.publicKey,
        );

        throw Exception(LocaleKeys.no_accounts.tr());
      }

      final result = await showChangeAccountModal(
        context: context,
        permissions: permissions,
        origin: origin,
      );

      if (result != null) {
        completer.complete(result);
      } else {
        throw Exception(LocaleKeys.not_granted.tr());
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
        throw Exception(LocaleKeys.not_granted.tr());
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
        throw Exception(LocaleKeys.no_password.tr());
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
        throw Exception(LocaleKeys.no_password.tr());
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
        throw Exception(LocaleKeys.no_password.tr());
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
        throw Exception(LocaleKeys.no_password.tr());
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
      final publicKeys = await getLocalCustodiansPublicKeys(sender);

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
        throw Exception(LocaleKeys.no_password.tr());
      }
    } catch (err, st) {
      completer.completeError(err, st);
    }
  }
}
