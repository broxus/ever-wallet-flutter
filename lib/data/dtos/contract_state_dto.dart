import 'package:crystal/data/dtos/gen_timings_dto.dart';
import 'package:crystal/data/dtos/last_transaction_id_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'contract_state_dto.freezed.dart';
part 'contract_state_dto.g.dart';

@freezed
class ContractStateDto with _$ContractStateDto {
  @HiveType(typeId: 4)
  const factory ContractStateDto({
    @HiveField(0) required String balance,
    @HiveField(1) required GenTimingsDto genTimings,
    @HiveField(2) LastTransactionIdDto? lastTransactionId,
    @HiveField(3) required bool isDeployed,
  }) = _ContractStateDto;
}

extension ContractStateDtoToDomain on ContractStateDto {
  ContractState toModel() => ContractState(
        balance: balance,
        genTimings: genTimings.toModel(),
        lastTransactionId: lastTransactionId?.toModel(),
        isDeployed: isDeployed,
      );
}

extension ContractStateFromDomain on ContractState {
  ContractStateDto toDto() => ContractStateDto(
        balance: balance,
        genTimings: genTimings.toDto(),
        lastTransactionId: lastTransactionId?.toDto(),
        isDeployed: isDeployed,
      );
}
