import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'approvals_bloc.freezed.dart';

@injectable
class ApprovalsBloc extends Bloc<ApprovalsEvent, ApprovalsState> {
  final NekotonService _nekotonService;

  ApprovalsBloc(this._nekotonService) : super(ApprovalsStateInitial()) {
    _nekotonService.approvalStream.listen((event) => add(ApprovalsEvent.show(event)));
  }

  @override
  Stream<ApprovalsState> mapEventToState(ApprovalsEvent event) async* {
    try {
      if (event is _Show) {
        yield ApprovalsStateShown(event.request);
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield ApprovalsStateError(err);
    }
  }
}

@freezed
class ApprovalsEvent with _$ApprovalsEvent {
  const factory ApprovalsEvent.show(ApprovalRequest request) = _Show;
}

abstract class ApprovalsState {}

class ApprovalsStateInitial extends ApprovalsState {}

class ApprovalsStateShown extends ApprovalsState {
  final ApprovalRequest request;

  ApprovalsStateShown(this.request);
}

class ApprovalsStateError extends ApprovalsState {
  final Exception exception;

  ApprovalsStateError(this.exception);
}
