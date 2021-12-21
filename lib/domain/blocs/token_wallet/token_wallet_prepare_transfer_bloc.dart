import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'token_wallet_prepare_transfer_bloc.freezed.dart';

@injectable
class TokenWalletPrepareTransferBloc extends Bloc<TokenWalletPrepareTransferEvent, TokenWalletPrepareTransferState> {
  final NekotonService _nekotonService;

  TokenWalletPrepareTransferBloc(this._nekotonService) : super(const TokenWalletPrepareTransferState.initial());

  @override
  Stream<TokenWalletPrepareTransferState> mapEventToState(TokenWalletPrepareTransferEvent event) async* {
    try {
      if (event is _PrepareTransfer) {
        final tokenWallet = _nekotonService.tokenWallets
            .firstWhereOrNull((e) => e.owner == event.owner && e.symbol.rootTokenContract == event.rootTokenContract);

        if (tokenWallet == null) {
          throw TokenWalletNotFoundException();
        }

        final repackedDestination = repackAddress(event.destination);

        final message = await tokenWallet.prepareTransfer(
          publicKey: event.publicKey,
          expiration: kDefaultMessageExpiration,
          destination: repackedDestination,
          tokens: event.amount,
          notifyReceiver: event.notifyReceiver,
          payload: event.payload,
        );

        yield TokenWalletPrepareTransferState.success(message);
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      yield TokenWalletPrepareTransferState.error(err);
    }
  }
}

@freezed
class TokenWalletPrepareTransferEvent with _$TokenWalletPrepareTransferEvent {
  const factory TokenWalletPrepareTransferEvent.prepareTransfer({
    required String owner,
    required String rootTokenContract,
    required String publicKey,
    required String destination,
    required String amount,
    required bool notifyReceiver,
    String? payload,
  }) = _PrepareTransfer;
}

@freezed
class TokenWalletPrepareTransferState with _$TokenWalletPrepareTransferState {
  const factory TokenWalletPrepareTransferState.initial() = _Initial;

  const factory TokenWalletPrepareTransferState.success(UnsignedMessage message) = _Success;

  const factory TokenWalletPrepareTransferState.error(Exception exception) = _Error;

  const TokenWalletPrepareTransferState._();

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => 0;
}
