import 'package:ever_wallet/data/models/permission.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_permissions_input.freezed.dart';
part 'request_permissions_input.g.dart';

@freezed
class RequestPermissionsInput with _$RequestPermissionsInput {
  const factory RequestPermissionsInput({
    required List<Permission> permissions,
  }) = _RequestPermissionsInput;

  factory RequestPermissionsInput.fromJson(Map<String, dynamic> json) =>
      _$RequestPermissionsInputFromJson(json);
}
