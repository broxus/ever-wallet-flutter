import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'approvals_bloc.freezed.dart';

@injectable
class ApprovalsBloc extends Bloc<ApprovalsEvent, ApprovalsState> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<String>();

  ApprovalsBloc(this._nekotonService) : super(const ApprovalsState.initial()) {
    _nekotonService.approvalStream.listen((event) => add(ApprovalsEvent.show(event)));
  }

  @override
  Future<void> close() {
    _errorsSubject.close();
    return super.close();
  }

  @override
  Stream<ApprovalsState> mapEventToState(ApprovalsEvent event) async* {
    try {
      if (event is _Show) {
        yield ApprovalsState.shown(event.request);
      }
    } catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err.toString());
    }
  }

  Stream<String> get errorsStream => _errorsSubject.stream;
}

@freezed
class ApprovalsEvent with _$ApprovalsEvent {
  const factory ApprovalsEvent.show(ApprovalRequest request) = _Show;
}

@freezed
class ApprovalsState with _$ApprovalsState {
  const factory ApprovalsState.initial() = _Initial;

  const factory ApprovalsState.shown(ApprovalRequest request) = _Shown;
}
