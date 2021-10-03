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

    // Future.delayed(const Duration(seconds: 3)).then((_) {
    //   print('AAA');
    //   add(ApprovalsEvent.showApproval(ApprovalRequest.callContractMethod(
    //     origin: "origin",
    //     selectedPublicKey: "selectedPublicKey",
    //     repackedRecipient: "repackedRecipient",
    //     payload: const FunctionCall(
    //       abi: "abi",
    //       method: "method",
    //       params: "params",
    //     ),
    //     completer: Completer<String>(),
    //   )));
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
