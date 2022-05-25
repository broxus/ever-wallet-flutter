import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import 'permission.dart';
import 'permissions.dart';

part 'approval_request.freezed.dart';

@freezed
class ApprovalRequest with _$ApprovalRequest {
  const factory ApprovalRequest.requestPermissions({
    required String origin,
    required List<Permission> permissions,
    required Completer<Permissions> completer,
  }) = _RequestPermissions;

  const factory ApprovalRequest.changeAccount({
    required String origin,
    required List<Permission> permissions,
    required Completer<Permissions> completer,
  }) = _ChangeAccount;

  const factory ApprovalRequest.addTip3Token({
    required String origin,
    required String account,
    required RootTokenContractDetails details,
    required Completer<void> completer,
  }) = _AddTip3Token;

  const factory ApprovalRequest.signData({
    required String origin,
    required String publicKey,
    required String data,
    required Completer<String> completer,
  }) = _SignData;

  const factory ApprovalRequest.encryptData({
    required String origin,
    required String publicKey,
    required String data,
    required Completer<String> completer,
  }) = _EncryptData;

  const factory ApprovalRequest.decryptData({
    required String origin,
    required String publicKey,
    required String sourcePublicKey,
    required Completer<String> completer,
  }) = _DecryptData;

  const factory ApprovalRequest.callContractMethod({
    required String origin,
    required String publicKey,
    required String recipient,
    required FunctionCall payload,
    required Completer<String> completer,
  }) = _CallContractMethod;

  const factory ApprovalRequest.sendMessage({
    required String origin,
    required String sender,
    required String recipient,
    required String amount,
    required bool bounce,
    required FunctionCall? payload,
    required KnownPayload? knownPayload,
    required Completer<Tuple2<String, String>> completer,
  }) = _SendMessage;
}
