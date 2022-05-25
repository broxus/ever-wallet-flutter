import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../models/approval_request.dart';
import '../models/permission.dart';
import '../models/permissions.dart';

@lazySingleton
class ApprovalsRepository {
  final _approvalsSubject = PublishSubject<ApprovalRequest>();

  ApprovalsRepository();

  Stream<ApprovalRequest> get approvalsStream => _approvalsSubject;

  Future<Permissions> requestPermissions({
    required String origin,
    required List<Permission> permissions,
  }) async {
    final completer = Completer<Permissions>();

    final request = ApprovalRequest.requestPermissions(
      origin: origin,
      permissions: permissions,
      completer: completer,
    );

    _approvalsSubject.add(request);

    return completer.future;
  }

  Future<Permissions> changeAccount({
    required String origin,
    required List<Permission> permissions,
  }) async {
    final completer = Completer<Permissions>();

    final request = ApprovalRequest.changeAccount(
      origin: origin,
      permissions: permissions,
      completer: completer,
    );

    _approvalsSubject.add(request);

    return completer.future;
  }

  Future<void> addTip3Token({
    required String origin,
    required String account,
    required RootTokenContractDetails details,
  }) async {
    final completer = Completer<void>();

    final request = ApprovalRequest.addTip3Token(
      origin: origin,
      account: account,
      details: details,
      completer: completer,
    );

    _approvalsSubject.add(request);

    return completer.future;
  }

  Future<String> signData({
    required String origin,
    required String publicKey,
    required String data,
  }) async {
    final completer = Completer<String>();

    final request = ApprovalRequest.signData(
      origin: origin,
      publicKey: publicKey,
      data: data,
      completer: completer,
    );

    _approvalsSubject.add(request);

    return completer.future;
  }

  Future<String> encryptData({
    required String origin,
    required String publicKey,
    required String data,
  }) async {
    final completer = Completer<String>();

    final request = ApprovalRequest.encryptData(
      origin: origin,
      publicKey: publicKey,
      data: data,
      completer: completer,
    );

    _approvalsSubject.add(request);

    return completer.future;
  }

  Future<String> decryptData({
    required String origin,
    required String publicKey,
    required String sourcePublicKey,
  }) async {
    final completer = Completer<String>();

    final request = ApprovalRequest.decryptData(
      origin: origin,
      publicKey: publicKey,
      sourcePublicKey: sourcePublicKey,
      completer: completer,
    );

    _approvalsSubject.add(request);

    return completer.future;
  }

  Future<String> callContractMethod({
    required String origin,
    required String publicKey,
    required String recipient,
    required FunctionCall payload,
  }) async {
    final completer = Completer<String>();

    final request = ApprovalRequest.callContractMethod(
      origin: origin,
      publicKey: publicKey,
      recipient: recipient,
      payload: payload,
      completer: completer,
    );

    _approvalsSubject.add(request);

    return completer.future;
  }

  Future<Tuple2<String, String>> sendMessage({
    required String origin,
    required String sender,
    required String recipient,
    required String amount,
    required bool bounce,
    required FunctionCall? payload,
    required KnownPayload? knownPayload,
  }) async {
    final completer = Completer<Tuple2<String, String>>();

    final request = ApprovalRequest.sendMessage(
      origin: origin,
      sender: sender,
      recipient: recipient,
      amount: amount,
      bounce: bounce,
      payload: payload,
      knownPayload: knownPayload,
      completer: completer,
    );

    _approvalsSubject.add(request);

    return completer.future;
  }
}
