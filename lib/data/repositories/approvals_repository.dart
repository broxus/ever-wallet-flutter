import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../models/approval_request.dart';

@lazySingleton
class ApprovalsRepository {
  final _approvalsSubject = PublishSubject<ApprovalRequest>();

  Stream<ApprovalRequest> get approvalsStream => _approvalsSubject.stream;

  Future<Permissions> requestApprovalForPermissions({
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

  Future<Tuple2<String, String>> requestApprovalToSendMessage({
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

  Future<String> requestApprovalToCallContractMethod({
    required String origin,
    required String selectedPublicKey,
    required String repackedRecipient,
    required FunctionCall payload,
  }) async {
    final completer = Completer<String>();

    final request = ApprovalRequest.callContractMethod(
      origin: origin,
      selectedPublicKey: selectedPublicKey,
      repackedRecipient: repackedRecipient,
      payload: payload,
      completer: completer,
    );

    _approvalsSubject.add(request);

    return completer.future;
  }
}
