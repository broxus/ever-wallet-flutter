import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_incoming_transfer_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_outgoing_transfer_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/token_swap_back_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_wallet_transaction_dto.freezed.dart';
part 'token_wallet_transaction_dto.g.dart';

@freezedDto
class TokenWalletTransactionDto with _$TokenWalletTransactionDto {
  @HiveType(typeId: 28)
  const factory TokenWalletTransactionDto.incomingTransfer(
    @HiveField(0) TokenIncomingTransferDto data,
  ) = _TokenWalletTransactionDtoIncomingTransfer;

  @HiveType(typeId: 29)
  const factory TokenWalletTransactionDto.outgoingTransfer(
    @HiveField(0) TokenOutgoingTransferDto data,
  ) = _TokenWalletTransactionDtoOutgoingTransfer;

  @HiveType(typeId: 30)
  const factory TokenWalletTransactionDto.swapBack(@HiveField(0) TokenSwapBackDto data) =
      _TokenWalletTransactionDtoSwapBack;

  @HiveType(typeId: 31)
  const factory TokenWalletTransactionDto.accept(@HiveField(0) String data) =
      _TokenWalletTransactionDtoAccept;

  @HiveType(typeId: 32)
  const factory TokenWalletTransactionDto.transferBounced(@HiveField(0) String data) =
      _TokenWalletTransactionDtoTransferBounced;

  @HiveType(typeId: 33)
  const factory TokenWalletTransactionDto.swapBackBounced(@HiveField(0) String data) =
      _TokenWalletTransactionDtoSwapBackBounced;
}

extension TokenWalletTransactionX on TokenWalletTransaction {
  TokenWalletTransactionDto toDto() => when(
        incomingTransfer: (data) => TokenWalletTransactionDto.incomingTransfer(data.toDto()),
        outgoingTransfer: (data) => TokenWalletTransactionDto.outgoingTransfer(data.toDto()),
        swapBack: (data) => TokenWalletTransactionDto.swapBack(data.toDto()),
        accept: (data) => TokenWalletTransactionDto.accept(data),
        transferBounced: (data) => TokenWalletTransactionDto.transferBounced(data),
        swapBackBounced: (data) => TokenWalletTransactionDto.swapBackBounced(data),
      );
}

extension TokenWalletTransactionDtoX on TokenWalletTransactionDto {
  TokenWalletTransaction toModel() => when(
        incomingTransfer: (data) => TokenWalletTransaction.incomingTransfer(data.toModel()),
        outgoingTransfer: (data) => TokenWalletTransaction.outgoingTransfer(data.toModel()),
        swapBack: (data) => TokenWalletTransaction.swapBack(data.toModel()),
        accept: (data) => TokenWalletTransaction.accept(data),
        transferBounced: (data) => TokenWalletTransaction.transferBounced(data),
        swapBackBounced: (data) => TokenWalletTransaction.swapBackBounced(data),
      );
}
