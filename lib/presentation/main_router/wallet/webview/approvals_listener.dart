import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../domain/blocs/provider/approvals_bloc.dart';
import '../../../../injection.dart';
import 'approval_dialogs.dart';

class ApprovalsListener extends StatefulWidget {
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
  _ApprovalsListenerState createState() => _ApprovalsListenerState();
}

class _ApprovalsListenerState extends State<ApprovalsListener> {
  final approvalsBloc = getIt.get<ApprovalsBloc>();

  @override
  void dispose() {
    approvalsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<ApprovalsBloc, ApprovalsState>(
        bloc: approvalsBloc,
        listener: (context, state) async {
          state.maybeWhen(
            requested: (request) => request.when(
              requestPermissions: (origin, permissions, completer) => onRequestPermissions(
                origin: origin,
                permissions: permissions,
                completer: completer,
                address: widget.address,
                publicKey: widget.publicKey,
                walletType: widget.walletType,
              ),
              sendMessage: (origin, sender, recipient, amount, bounce, payload, knownPayload, completer) =>
                  onSendMessage(
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
                  onCallContractMethod(
                origin: origin,
                selectedPublicKey: selectedPublicKey,
                repackedRecipient: repackedRecipient,
                payload: payload,
                completer: completer,
              ),
            ),
            orElse: () => null,
          );
        },
        child: widget.child,
      );

  Future<void> onRequestPermissions({
    required String origin,
    required List<Permission> permissions,
    required Completer<Permissions> completer,
    required String address,
    required String publicKey,
    required WalletType walletType,
  }) async {
    final result = await showRequestPermissionsDialog(
      context,
      origin: origin,
      permissions: permissions,
      address: address,
      publicKey: publicKey,
    );

    if (result) {
      var grantedPermissions = const Permissions();

      for (final permission in permissions) {
        switch (permission) {
          case Permission.tonClient:
            grantedPermissions = grantedPermissions.copyWith(tonClient: true);
            break;
          case Permission.accountInteraction:
            final contractType = walletType.when(
              multisig: (multisigType) {
                switch (multisigType) {
                  case MultisigType.safeMultisigWallet:
                    return WalletContractType.safeMultisigWallet;
                  case MultisigType.safeMultisigWallet24h:
                    return WalletContractType.safeMultisigWallet24h;
                  case MultisigType.setcodeMultisigWallet:
                    return WalletContractType.setcodeMultisigWallet;
                  case MultisigType.bridgeMultisigWallet:
                    return WalletContractType.bridgeMultisigWallet;
                  case MultisigType.surfWallet:
                    return WalletContractType.surfWallet;
                }
              },
              walletV3: () => WalletContractType.walletV3,
            );

            grantedPermissions = grantedPermissions.copyWith(
              accountInteraction: AccountInteraction(
                address: address,
                publicKey: publicKey,
                contractType: contractType,
              ),
            );
            break;
        }
      }

      completer.complete(grantedPermissions);
    } else {
      completer.completeError(Exception('Not granted'));
    }
  }

  Future<void> onSendMessage({
    required String origin,
    required String sender,
    required String recipient,
    required String amount,
    required bool bounce,
    required FunctionCall? payload,
    required KnownPayload? knownPayload,
    required Completer<String> completer,
  }) async {
    final result = await showSendMessageDialog(
      context,
      origin: origin,
      sender: sender,
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

  Future<void> onCallContractMethod({
    required String origin,
    required String selectedPublicKey,
    required String repackedRecipient,
    required FunctionCall payload,
    required Completer<String> completer,
  }) async {
    final result = await showCallContractMethodDialog(
      context,
      origin: origin,
      selectedPublicKey: selectedPublicKey,
      repackedRecipient: repackedRecipient,
      payload: payload,
    );

    if (result != null) {
      completer.complete(result);
    } else {
      completer.completeError(Exception('No password'));
    }
  }
}
