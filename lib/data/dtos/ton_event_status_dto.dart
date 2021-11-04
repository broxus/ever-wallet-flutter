import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'ton_event_status_dto.g.dart';

@HiveType(typeId: 39)
enum TonEventStatusDto {
  @HiveField(0)
  inProcess,
  @HiveField(1)
  confirmed,
  @HiveField(2)
  rejected,
}

extension TonEventStatusDtoToDomain on TonEventStatusDto {
  TonEventStatus toModel() => TonEventStatus.values[index];
}

extension TonEventStatusFromDomain on TonEventStatus {
  TonEventStatusDto toDto() => TonEventStatusDto.values[index];
}
