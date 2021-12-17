import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../../../../../../../injection.dart';
import '../../../../../data/repositories/biometry_repository.dart';
import 'call_contract_method_body.dart';
import 'request_permissions_body.dart';
import 'send_message_body.dart';
import 'submit_send_body.dart';

Future<bool> showRequestPermissionsDialog(
  BuildContext context, {
  required String origin,
  required List<Permission> permissions,
  required String address,
  required String publicKey,
}) =>
    RequestPermissionsBody.open(
      context: context,
      origin: origin,
      permissions: permissions,
      address: address,
      publicKey: publicKey,
    ).then((value) => value ?? false);

Future<String?> showSendMessageDialog(
  BuildContext context, {
  required String origin,
  required String sender,
  required String publicKey,
  required String recipient,
  required String amount,
  required bool bounce,
  required FunctionCall? payload,
  required KnownPayload? knownPayload,
}) async {
  final result = await SendMessageBody.open(
        context: context,
        origin: origin,
        sender: sender,
        publicKey: publicKey,
        recipient: recipient,
        amount: amount,
        bounce: bounce,
        payload: payload,
        knownPayload: knownPayload,
      ) ??
      false;

  if (result) {
    String? password;

    final biometryInfoBloc = context.read<BiometryInfoBloc>();

    if (biometryInfoBloc.state.isAvailable && biometryInfoBloc.state.isEnabled) {
      try {
        password = await getIt.get<BiometryRepository>().getKeyPassword(
              localizedReason: 'Please authenticate to interact with wallet',
              publicKey: publicKey,
            );
      } catch (err) {
        password == null;
      }

      password ??= await SubmitSendBody.open(
        context: context,
        publicKey: publicKey,
      );
    } else {
      password = await SubmitSendBody.open(
        context: context,
        publicKey: publicKey,
      );
    }

    return password;
  } else {
    return null;
  }
}

Future<String?> showCallContractMethodDialog(
  BuildContext context, {
  required String origin,
  required String selectedPublicKey,
  required String repackedRecipient,
  required FunctionCall? payload,
}) async {
  final result = await CallContractMethodBody.open(
        context: context,
        origin: origin,
        publicKey: selectedPublicKey,
        recipient: repackedRecipient,
        payload: payload,
      ) ??
      false;

  if (result) {
    String? password;

    final biometryInfoBloc = context.read<BiometryInfoBloc>();

    if (biometryInfoBloc.state.isAvailable && biometryInfoBloc.state.isEnabled) {
      try {
        password = await getIt.get<BiometryRepository>().getKeyPassword(
              localizedReason: 'Please authenticate to interact with wallet',
              publicKey: selectedPublicKey,
            );
      } catch (err) {
        password == null;
      }

      password ??= await SubmitSendBody.open(
        context: context,
        publicKey: selectedPublicKey,
      );
    } else {
      password = await SubmitSendBody.open(
        context: context,
        publicKey: selectedPublicKey,
      );
    }

    return password;
  } else {
    return null;
  }
}
