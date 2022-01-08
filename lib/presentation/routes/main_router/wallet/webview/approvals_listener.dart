import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../domain/blocs/provider/approvals_provider.dart';
import '../modals/call_contract_method/show_call_contract_method.dart';
import '../modals/request_permissions_modal/show_preferences_modal.dart';
import '../modals/send_message/show_send_message.dart';

class ApprovalsListener extends StatelessWidget {
  final String address;
  final String publicKey;
  final WalletType walletType;
  final Widget child;

  const ApprovalsListener({
    Key? key,
    required this.address,
    required this.publicKey,
    required this.walletType,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue<ApprovalRequest>>(
            approvalsProvider,
            (previous, next) => next.asData?.value.when(
              requestPermissions: (origin, permissions, completer) => requestPermissions(
                context: context,
                origin: origin,
                permissions: permissions,
                completer: completer,
              ),
              sendMessage: (origin, sender, recipient, amount, bounce, payload, knownPayload, completer) => sendMessage(
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
              callContractMethod: (origin, selectedPublicKey, repackedRecipient, payload, completer) =>
                  callContractMethod(
                context: context,
                origin: origin,
                selectedPublicKey: selectedPublicKey,
                repackedRecipient: repackedRecipient,
                payload: payload,
                completer: completer,
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
    final result = await showRequestPermissionsModal(
      context: context,
      origin: origin,
      permissions: permissions,
      address: address,
      publicKey: publicKey,
    );

    if (result != null) {
      completer.complete(result);
    } else {
      completer.completeError(Exception('Not granted'));
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
    required Completer<String> completer,
  }) async {
    final result = await showSendMessage(
      context: context,
      origin: origin,
      sender: sender,
      publicKey: publicKey,
      recipient: recipient,
      amount: amount,
      bounce: bounce,
      payload: payload,
      knownPayload: knownPayload,
    );

    if (result != null) {
      completer.complete(result);
    } else {
      completer.completeError(Exception('No password'));
    }
  }

  Future<void> callContractMethod({
    required BuildContext context,
    required String origin,
    required String selectedPublicKey,
    required String repackedRecipient,
    required FunctionCall payload,
    required Completer<String> completer,
  }) async {
    final result = await showCallContractMethod(
      context: context,
      origin: origin,
      publicKey: selectedPublicKey,
      recipient: repackedRecipient,
      payload: payload,
    );

    if (result != null) {
      completer.complete(result);
    } else {
      completer.completeError(Exception('No password'));
    }
  }
}
