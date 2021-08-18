import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../../domain/models/connected_site.dart';

part 'connected_site_dto.freezed.dart';
part 'connected_site_dto.g.dart';

@freezed
@HiveType(typeId: 0)
class ConnectedSiteDto with _$ConnectedSiteDto {
  const factory ConnectedSiteDto({
    @HiveField(0) required String url,
    @HiveField(1) required String time,
  }) = _ConnectedSiteDto;

  factory ConnectedSiteDto.fromDomain(ConnectedSite connectedSite) => ConnectedSiteDto(
        url: connectedSite.url,
        time: connectedSite.time.toIso8601String(),
      );

  const ConnectedSiteDto._();

  ConnectedSite toDomain() => ConnectedSite(
        url: url,
        time: DateTime.parse(time),
      );
}
