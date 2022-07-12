import 'package:ever_wallet/data/models/permissions.dart';
import 'package:ever_wallet/data/sources/local/hive/dto/account_interaction_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'permissions_dto.freezed.dart';
part 'permissions_dto.g.dart';

@freezed
class PermissionsDto with _$PermissionsDto {
  @HiveType(typeId: 223)
  const factory PermissionsDto({
    @HiveField(0) bool? basic,
    @HiveField(1) AccountInteractionDto? accountInteraction,
  }) = _PermissionsDto;
}

extension PermissionsX on Permissions {
  PermissionsDto toDto() => PermissionsDto(
        basic: basic,
        accountInteraction: accountInteraction?.toDto(),
      );
}

extension PermissionsDtoX on PermissionsDto {
  Permissions toModel() => Permissions(
        basic: basic,
        accountInteraction: accountInteraction?.toModel(),
      );
}
