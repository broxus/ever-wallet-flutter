import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:crystal/domain/services/nekoton_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';

part 'provider_requests_bloc.freezed.dart';

@injectable
class ProviderRequestsBloc extends Bloc<ProviderRequestsEvent, ProviderRequestsState> {
  final NekotonService _nekotonService;

  ProviderRequestsBloc(this._nekotonService) : super(const ProviderRequestsState.initial());

  @override
  Stream<ProviderRequestsState> mapEventToState(ProviderRequestsEvent event) async* {
    yield* event.when(
      onRequestPermissions: (
        String origin,
        RequestPermissionsInput input,
      ) async* {
        final output = await _nekotonService.providerRequestPermissions(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.requestPermissions(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onDisconnect: (
        String origin,
      ) async* {
        await _nekotonService.providerDisconnect(origin: origin);

        yield ProviderRequestsState.disconnect(
          origin: origin,
          output: Object(),
        );
      },
      onSubscribe: (
        String origin,
        SubscribeInput input,
      ) async* {
        final output = await _nekotonService.providerSubscribe(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.subscribe(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onUnsubscribe: (
        String origin,
        UnsubscribeInput input,
      ) async* {
        _nekotonService.providerUnsubscribe(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.unsubscribe(
          origin: origin,
          input: input,
          output: Object(),
        );
      },
      onUnsubscribeAll: (
        String origin,
      ) async* {
        _nekotonService.providerUnsubscribeAll(
          origin: origin,
        );

        yield ProviderRequestsState.unsubscribeAll(
          origin: origin,
          output: Object(),
        );
      },
      onGetProviderState: (
        String origin,
      ) async* {
        final output = await _nekotonService.providerGetProviderState(
          origin: origin,
        );

        yield ProviderRequestsState.getProviderState(
          origin: origin,
          output: output,
        );
      },
      onGetFullContractState: (
        String origin,
        GetFullContractStateInput input,
      ) async* {
        final output = await _nekotonService.providerGetFullContractState(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.getFullContractState(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onGetTransactions: (
        String origin,
        GetTransactionsInput input,
      ) async* {
        final output = await _nekotonService.providerGetTransactions(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.getTransactions(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onRunLocal: (
        String origin,
        RunLocalInput input,
      ) async* {
        final output = await _nekotonService.providerRunLocal(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.runLocal(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onGetExpectedAddress: (
        String origin,
        GetExpectedAddressInput input,
      ) async* {
        final output = await _nekotonService.providerGetExpectedAddress(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.getExpectedAddress(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onPackIntoCell: (
        String origin,
        PackIntoCellInput input,
      ) async* {
        final output = await _nekotonService.providerPackIntoCell(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.packIntoCell(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onUnpackFromCell: (
        String origin,
        UnpackFromCellInput input,
      ) async* {
        final output = await _nekotonService.providerUnpackFromCell(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.unpackFromCell(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onExtractPublicKey: (
        String origin,
        ExtractPublicKeyInput input,
      ) async* {
        final output = await _nekotonService.providerExtractPublicKey(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.extractPublicKey(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onCodeToTvc: (
        String origin,
        CodeToTvcInput input,
      ) async* {
        final output = await _nekotonService.providerCodeToTvc(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.codeToTvc(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onSplitTvc: (
        String origin,
        SplitTvcInput input,
      ) async* {
        final output = await _nekotonService.providerSplitTvc(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.splitTvc(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onEncodeInternalInput: (
        String origin,
        EncodeInternalInputInput input,
      ) async* {
        final output = await _nekotonService.providerEncodeInternalInput(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.encodeInternalInput(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onDecodeInput: (
        String origin,
        DecodeInputInput input,
      ) async* {
        final output = await _nekotonService.providerDecodeInput(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.decodeInput(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onDecodeOutput: (
        String origin,
        DecodeOutputInput input,
      ) async* {
        final output = await _nekotonService.providerDecodeOutput(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.decodeOutput(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onDecodeEvent: (
        String origin,
        DecodeEventInput input,
      ) async* {
        final output = await _nekotonService.providerDecodeEvent(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.decodeEvent(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onDecodeTransaction: (
        String origin,
        DecodeTransactionInput input,
      ) async* {
        final output = await _nekotonService.providerDecodeTransaction(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.decodeTransaction(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onDecodeTransactionEvents: (
        String origin,
        DecodeTransactionEventsInput input,
      ) async* {
        final output = await _nekotonService.providerDecodeTransactionEvents(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.decodeTransactionEvents(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onEstimateFees: (
        String origin,
        EstimateFeesInput input,
      ) async* {
        final output = await _nekotonService.providerEstimateFees(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.estimateFees(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onSendMessage: (
        String origin,
        SendMessageInput input,
      ) async* {
        final output = await _nekotonService.providerSendMessage(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.sendMessage(
          origin: origin,
          input: input,
          output: output,
        );
      },
      onSendExternalMessage: (
        String origin,
        SendExternalMessageInput input,
      ) async* {
        final output = await _nekotonService.providerSendExternalMessage(
          origin: origin,
          input: input,
        );

        yield ProviderRequestsState.sendExternalMessage(
          origin: origin,
          input: input,
          output: output,
        );
      },
    ).handleError((Object err, StackTrace st) {
      logger.e(err, err, st);
    });
  }
}

@freezed
class ProviderRequestsEvent with _$ProviderRequestsEvent {
  const factory ProviderRequestsEvent.onRequestPermissions({
    required String origin,
    required RequestPermissionsInput input,
  }) = _OnRequestPermissions;

  const factory ProviderRequestsEvent.onDisconnect({
    required String origin,
  }) = _OnDisconnect;

  const factory ProviderRequestsEvent.onSubscribe({
    required String origin,
    required SubscribeInput input,
  }) = _OnSubscribe;

  const factory ProviderRequestsEvent.onUnsubscribe({
    required String origin,
    required UnsubscribeInput input,
  }) = _OnUnsubscribe;

  const factory ProviderRequestsEvent.onUnsubscribeAll({
    required String origin,
  }) = _OnUnsubscribeAll;

  const factory ProviderRequestsEvent.onGetProviderState({
    required String origin,
  }) = _OnGetProviderState;

  const factory ProviderRequestsEvent.onGetFullContractState({
    required String origin,
    required GetFullContractStateInput input,
  }) = _OnGetFullContractState;

  const factory ProviderRequestsEvent.onGetTransactions({
    required String origin,
    required GetTransactionsInput input,
  }) = _OnGetTransactions;

  const factory ProviderRequestsEvent.onRunLocal({
    required String origin,
    required RunLocalInput input,
  }) = _OnRunLocal;

  const factory ProviderRequestsEvent.onGetExpectedAddress({
    required String origin,
    required GetExpectedAddressInput input,
  }) = _OnGetExpectedAddress;

  const factory ProviderRequestsEvent.onPackIntoCell({
    required String origin,
    required PackIntoCellInput input,
  }) = _OnPackIntoCell;

  const factory ProviderRequestsEvent.onUnpackFromCell({
    required String origin,
    required UnpackFromCellInput input,
  }) = _OnUnpackFromCell;

  const factory ProviderRequestsEvent.onExtractPublicKey({
    required String origin,
    required ExtractPublicKeyInput input,
  }) = _OnExtractPublicKey;

  const factory ProviderRequestsEvent.onCodeToTvc({
    required String origin,
    required CodeToTvcInput input,
  }) = _OnCodeToTvc;

  const factory ProviderRequestsEvent.onSplitTvc({
    required String origin,
    required SplitTvcInput input,
  }) = _OnSplitTvc;

  const factory ProviderRequestsEvent.onEncodeInternalInput({
    required String origin,
    required EncodeInternalInputInput input,
  }) = _OnEncodeInternalInput;

  const factory ProviderRequestsEvent.onDecodeInput({
    required String origin,
    required DecodeInputInput input,
  }) = _OnDecodeInput;

  const factory ProviderRequestsEvent.onDecodeOutput({
    required String origin,
    required DecodeOutputInput input,
  }) = _OnDecodeOutput;

  const factory ProviderRequestsEvent.onDecodeEvent({
    required String origin,
    required DecodeEventInput input,
  }) = _OnDecodeEvent;

  const factory ProviderRequestsEvent.onDecodeTransaction({
    required String origin,
    required DecodeTransactionInput input,
  }) = _OnDecodeTransaction;

  const factory ProviderRequestsEvent.onDecodeTransactionEvents({
    required String origin,
    required DecodeTransactionEventsInput input,
  }) = _OnDecodeTransactionEvents;

  const factory ProviderRequestsEvent.onEstimateFees({
    required String origin,
    required EstimateFeesInput input,
  }) = _OnEstimateFees;

  const factory ProviderRequestsEvent.onSendMessage({
    required String origin,
    required SendMessageInput input,
  }) = _OnSendMessage;

  const factory ProviderRequestsEvent.onSendExternalMessage({
    required String origin,
    required SendExternalMessageInput input,
  }) = _OnSendExternalMessage;
}

@freezed
class ProviderRequestsState with _$ProviderRequestsState {
  const factory ProviderRequestsState.initial() = _Initial;

  const factory ProviderRequestsState.requestPermissions({
    required String origin,
    required RequestPermissionsInput input,
    required RequestPermissionsOutput output,
  }) = _RequestPermissions;

  const factory ProviderRequestsState.disconnect({
    required String origin,
    required Object output,
  }) = _Disconnect;

  const factory ProviderRequestsState.subscribe({
    required String origin,
    required SubscribeInput input,
    required SubscribeOutput output,
  }) = _Subscribe;

  const factory ProviderRequestsState.unsubscribe({
    required String origin,
    required UnsubscribeInput input,
    required Object output,
  }) = _Unsubscribe;

  const factory ProviderRequestsState.unsubscribeAll({
    required String origin,
    required Object output,
  }) = _UnsubscribeAll;

  const factory ProviderRequestsState.getProviderState({
    required String origin,
    required GetProviderStateOutput output,
  }) = _GetProviderState;

  const factory ProviderRequestsState.getFullContractState({
    required String origin,
    required GetFullContractStateInput input,
    required GetFullContractStateOutput output,
  }) = _GetFullContractState;

  const factory ProviderRequestsState.getTransactions({
    required String origin,
    required GetTransactionsInput input,
    required GetTransactionsOutput output,
  }) = _GetTransactions;

  const factory ProviderRequestsState.runLocal({
    required String origin,
    required RunLocalInput input,
    required RunLocalOutput output,
  }) = _RunLocal;

  const factory ProviderRequestsState.getExpectedAddress({
    required String origin,
    required GetExpectedAddressInput input,
    required GetExpectedAddressOutput output,
  }) = _GetExpectedAddress;

  const factory ProviderRequestsState.packIntoCell({
    required String origin,
    required PackIntoCellInput input,
    required PackIntoCellOutput output,
  }) = _PackIntoCell;

  const factory ProviderRequestsState.unpackFromCell({
    required String origin,
    required UnpackFromCellInput input,
    required UnpackFromCellOutput output,
  }) = _UnpackFromCell;

  const factory ProviderRequestsState.extractPublicKey({
    required String origin,
    required ExtractPublicKeyInput input,
    required ExtractPublicKeyOutput output,
  }) = _ExtractPublicKey;

  const factory ProviderRequestsState.codeToTvc({
    required String origin,
    required CodeToTvcInput input,
    required CodeToTvcOutput output,
  }) = _CodeToTvc;

  const factory ProviderRequestsState.splitTvc({
    required String origin,
    required SplitTvcInput input,
    required SplitTvcOutput output,
  }) = _SplitTvc;

  const factory ProviderRequestsState.encodeInternalInput({
    required String origin,
    required EncodeInternalInputInput input,
    required EncodeInternalInputOutput output,
  }) = _EncodeInternalInput;

  const factory ProviderRequestsState.decodeInput({
    required String origin,
    required DecodeInputInput input,
    required DecodeInputOutput? output,
  }) = _DecodeInput;

  const factory ProviderRequestsState.decodeOutput({
    required String origin,
    required DecodeOutputInput input,
    required DecodeOutputOutput? output,
  }) = _DecodeOutput;

  const factory ProviderRequestsState.decodeEvent({
    required String origin,
    required DecodeEventInput input,
    required DecodeEventOutput? output,
  }) = _DecodeEvent;

  const factory ProviderRequestsState.decodeTransaction({
    required String origin,
    required DecodeTransactionInput input,
    required DecodeTransactionOutput? output,
  }) = _DecodeTransaction;

  const factory ProviderRequestsState.decodeTransactionEvents({
    required String origin,
    required DecodeTransactionEventsInput input,
    required DecodeTransactionEventsOutput output,
  }) = _DecodeTransactionEvents;

  const factory ProviderRequestsState.estimateFees({
    required String origin,
    required EstimateFeesInput input,
    required EstimateFeesOutput output,
  }) = _EstimateFees;

  const factory ProviderRequestsState.sendMessage({
    required String origin,
    required SendMessageInput input,
    required SendMessageOutput output,
  }) = _SendMessage;

  const factory ProviderRequestsState.sendExternalMessage({
    required String origin,
    required SendExternalMessageInput input,
    required SendExternalMessageOutput output,
  }) = _SendExternalMessage;
}
