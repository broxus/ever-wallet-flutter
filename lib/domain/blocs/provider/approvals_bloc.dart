import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:crystal/domain/services/nekoton_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'approvals_bloc.freezed.dart';

@injectable
class ApprovalsBloc extends Bloc<ApprovalsEvent, ApprovalsState> {
  final NekotonService _nekotonService;

  ApprovalsBloc(this._nekotonService) : super(const ApprovalsState.initial()) {
    _nekotonService.approvalStream.listen((event) {
      add(ApprovalsEvent.showApproval(event));
    });

    // Future.delayed(const Duration(seconds: 3)).then((_) async {
    //   final completer = Completer<Permissions>();

    //   add(
    //     ApprovalsEvent.showApproval(
    //       ApprovalRequest.requestPermissions(
    //         origin: "https://tonswap.io",
    //         permissions: [
    //           Permission.tonClient,
    //           Permission.accountInteraction,
    //         ],
    //         completer: completer,
    //       ),
    //     ),
    //   );

    //   try {
    //     final perm = await completer.future;
    //     logger.i(perm);
    //   } catch (err, st) {
    //     logger.e(err, err, st);
    //   }
    // });

    // Future.delayed(const Duration(seconds: 3)).then((_) async {
    //   final completer = Completer<String>();

    //   add(
    //     ApprovalsEvent.showApproval(
    //       ApprovalRequest.sendMessage(
    //         origin: "https://tonswap.io",
    //         amount: '1000000000',
    //         bounce: false,
    //         knownPayload: null,
    //         payload: null,
    //         recipient: '0:aaaabbbbccccddddeeeeffffgggg',
    //         sender: '0:hhhhiiiijjjjkkkkllllmmmm',
    //         completer: completer,
    //       ),
    //     ),
    //   );

    //   try {
    //     final perm = await completer.future;
    //     logger.i(perm);
    //   } catch (err, st) {
    //     logger.e(err, err, st);
    //   }
    // });

    // Future.delayed(const Duration(seconds: 3)).then((_) async {
    //   final completer = Completer<String>();

    //   add(
    //     ApprovalsEvent.showApproval(
    //       ApprovalRequest.callContractMethod(
    //         origin: "https://tonswap.io",
    //         payload: const FunctionCall(
    //           abi: 'abi',
    //           method: 'method',
    //           params: null,
    //         ),
    //         repackedRecipient: '0:aaaabbbbccccddddeeeeffffgggg',
    //         selectedPublicKey: 'hhhhiiiijjjjkkkkllllmmmm',
    //         completer: completer,
    //       ),
    //     ),
    //   );

    //   try {
    //     final perm = await completer.future;
    //     logger.i(perm);
    //   } catch (err, st) {
    //     logger.e(err, err, st);
    //   }
    // });
  }

  @override
  Stream<ApprovalsState> mapEventToState(ApprovalsEvent event) async* {
    yield* event.when(
      showApproval: (ApprovalRequest request) async* {
        yield ApprovalsState.requested(request);
      },
    );
  }
}

@freezed
class ApprovalsEvent with _$ApprovalsEvent {
  const factory ApprovalsEvent.showApproval(ApprovalRequest request) = _ShowApproval;
}

@freezed
class ApprovalsState with _$ApprovalsState {
  const factory ApprovalsState.initial() = _Initial;

  const factory ApprovalsState.requested(ApprovalRequest request) = _Requested;
}
