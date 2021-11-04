import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'account_status_dto.g.dart';

@HiveType(typeId: 10)
enum AccountStatusDto {
  @HiveField(0)
  uninit,
  @HiveField(1)
  frozen,
  @HiveField(2)
  active,
  @HiveField(3)
  nonexist,
}

extension AccountStatusDtoToDomain on AccountStatusDto {
  AccountStatus toModel() => AccountStatus.values[index];
}

extension AccountStatusFromDomain on AccountStatus {
  AccountStatusDto toDto() => AccountStatusDto.values[index];
}
