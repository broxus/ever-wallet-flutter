import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'account_status_dto.g.dart';

@HiveType(typeId: 5)
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

extension AccountStatusX on AccountStatus {
  AccountStatusDto toDto() {
    switch (this) {
      case AccountStatus.uninit:
        return AccountStatusDto.uninit;
      case AccountStatus.frozen:
        return AccountStatusDto.frozen;
      case AccountStatus.active:
        return AccountStatusDto.active;
      case AccountStatus.nonexist:
        return AccountStatusDto.nonexist;
    }
  }
}

extension AccountStatusDtoX on AccountStatusDto {
  AccountStatus toModel() {
    switch (this) {
      case AccountStatusDto.uninit:
        return AccountStatus.uninit;
      case AccountStatusDto.frozen:
        return AccountStatus.frozen;
      case AccountStatusDto.active:
        return AccountStatus.active;
      case AccountStatusDto.nonexist:
        return AccountStatus.nonexist;
    }
  }
}
