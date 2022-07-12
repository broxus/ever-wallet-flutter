import 'package:ever_wallet/data/sources/local/hive/dto/gen_timings_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/last_transaction_id_dto.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'contract_state_dto.freezed.dart';
part 'contract_state_dto.g.dart';

@freezedDto
class ContractStateDto with _$ContractStateDto {
  @HiveType(typeId: 6)
  const factory ContractStateDto({
    @HiveField(0) required String balance,
    @HiveField(1) required GenTimingsDto genTimings,
    @HiveField(2) LastTransactionIdDto? lastTransactionId,
    @HiveField(3) required bool isDeployed,
    @HiveField(4) String? codeHash,
  }) = _ContractStateDto;
}

extension ContractStateX on ContractState {
  ContractStateDto toDto() => ContractStateDto(
        balance: balance,
        genTimings: genTimings.toDto(),
        lastTransactionId: lastTransactionId?.toDto(),
        isDeployed: isDeployed,
        codeHash: codeHash,
      );
}

extension ContractStateDtoX on ContractStateDto {
  ContractState toModel() => ContractState(
        balance: balance,
        genTimings: genTimings.toModel(),
        lastTransactionId: lastTransactionId?.toModel(),
        isDeployed: isDeployed,
        codeHash: codeHash,
      );
}
