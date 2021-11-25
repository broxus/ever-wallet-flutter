import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'token_incoming_transfer_dto.dart';
import 'token_outgoing_transfer_dto.dart';
import 'token_swap_back_dto.dart';

part 'token_wallet_transaction_dto.freezed.dart';
part 'token_wallet_transaction_dto.g.dart';

@freezed
class TokenWalletTransactionDto with _$TokenWalletTransactionDto {
  @HiveType(typeId: 15)
  const factory TokenWalletTransactionDto.incomingTransfer({
    @HiveField(0) required TokenIncomingTransferDto tokenIncomingTransfer,
  }) = _IncomingTransferDto;

  @HiveType(typeId: 16)
  const factory TokenWalletTransactionDto.outgoingTransfer({
    @HiveField(0) required TokenOutgoingTransferDto tokenOutgoingTransfer,
  }) = _OutgoingTransferDto;

  @HiveType(typeId: 17)
  const factory TokenWalletTransactionDto.swapBack({
    @HiveField(0) required TokenSwapBackDto tokenSwapBack,
  }) = _SwapBackDto;

  @HiveType(typeId: 18)
  const factory TokenWalletTransactionDto.accept({
    @HiveField(0) required String value,
  }) = _AcceptDto;

  @HiveType(typeId: 19)
  const factory TokenWalletTransactionDto.transferBounced({
    @HiveField(0) required String value,
  }) = _TransferBouncedDto;

  @HiveType(typeId: 20)
  const factory TokenWalletTransactionDto.swapBackBounced({
    @HiveField(0) required String value,
  }) = _SwapBackBouncedDto;

  factory TokenWalletTransactionDto.fromJson(Map<String, dynamic> json) => _$TokenWalletTransactionDtoFromJson(json);
}

extension TokenWalletTransactionDtoToDomain on TokenWalletTransactionDto {
  TokenWalletTransaction toModel() => when(
        incomingTransfer: (tokenIncomingTransfer) =>
            TokenWalletTransaction.incomingTransfer(tokenIncomingTransfer: tokenIncomingTransfer.toModel()),
        outgoingTransfer: (tokenOutgoingTransfer) =>
            TokenWalletTransaction.outgoingTransfer(tokenOutgoingTransfer: tokenOutgoingTransfer.toModel()),
        swapBack: (tokenSwapBack) => TokenWalletTransaction.swapBack(tokenSwapBack: tokenSwapBack.toModel()),
        accept: (value) => TokenWalletTransaction.accept(value: value),
        transferBounced: (value) => TokenWalletTransaction.transferBounced(value: value),
        swapBackBounced: (value) => TokenWalletTransaction.swapBackBounced(value: value),
      );
}

extension TokenWalletTransactionFromDomain on TokenWalletTransaction {
  TokenWalletTransactionDto toDto() => when(
        incomingTransfer: (tokenIncomingTransfer) =>
            TokenWalletTransactionDto.incomingTransfer(tokenIncomingTransfer: tokenIncomingTransfer.toDto()),
        outgoingTransfer: (tokenOutgoingTransfer) =>
            TokenWalletTransactionDto.outgoingTransfer(tokenOutgoingTransfer: tokenOutgoingTransfer.toDto()),
        swapBack: (tokenSwapBack) => TokenWalletTransactionDto.swapBack(tokenSwapBack: tokenSwapBack.toDto()),
        accept: (value) => TokenWalletTransactionDto.accept(value: value),
        transferBounced: (value) => TokenWalletTransactionDto.transferBounced(value: value),
        swapBackBounced: (value) => TokenWalletTransactionDto.swapBackBounced(value: value),
      );
}
