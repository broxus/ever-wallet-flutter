import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'eth_event_status_dto.g.dart';

@HiveType(typeId: 28)
enum EthEventStatusDto {
  @HiveField(0)
  inProcess,
  @HiveField(1)
  confirmed,
  @HiveField(2)
  executed,
  @HiveField(3)
  rejected,
}

extension EthEventStatusDtoToDomain on EthEventStatusDto {
  EthEventStatus toModel() => EthEventStatus.values[index];
}

extension EthEventStatusFromDomain on EthEventStatus {
  EthEventStatusDto toDto() => EthEventStatusDto.values[index];
}
