import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/blocs/provider/approvals_bloc.dart';
import '../../../../../../../../injection.dart';
import '../modals/call_contract_method/show_call_contract_method.dart';
import '../modals/request_permissions_modal/show_preferences_modal.dart';
import '../modals/send_message/show_send_message.dart';

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
          if (state is ApprovalsStateShown) {
            state.request.when(
              requestPermissions: requestPermissions,
              sendMessage: sendMessage,
              callContractMethod: callContractMethod,
            );
          }
        },
        child: widget.child,
      );

  Future<void> requestPermissions(
    String origin,
    List<Permission> permissions,
    Completer<Permissions> completer,
  ) async {
    final result = await showRequestPermissionsModal(
      context: context,
      origin: origin,
      permissions: permissions,
      address: widget.address,
      publicKey: widget.publicKey,
    );

    if (result != null) {
      completer.complete(result);
    } else {
      completer.completeError(Exception('Not granted'));
    }
  }

  Future<void> sendMessage(
    String origin,
    String sender,
    String recipient,
    String amount,
    bool bounce,
    FunctionCall? payload,
    KnownPayload? knownPayload,
    Completer<String> completer,
  ) async {
    final result = await showSendMessage(
      context: context,
      origin: origin,
      sender: sender,
      publicKey: widget.publicKey,
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

  Future<void> callContractMethod(
    String origin,
    String selectedPublicKey,
    String repackedRecipient,
    FunctionCall payload,
    Completer<String> completer,
  ) async {
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
