import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/models/web_metadata.dart';

part 'web_metadata_dto.freezed.dart';
part 'web_metadata_dto.g.dart';

@freezed
class WebMetadataDto with _$WebMetadataDto {
  const factory WebMetadataDto({
    required String url,
    String? title,
    String? icon,
  }) = _WebMetadataDto;

  factory WebMetadataDto.fromJson(Map<String, dynamic> json) => _$WebMetadataDtoFromJson(json);

  factory WebMetadataDto.fromDomain(WebMetadata webMetadata) => WebMetadataDto(
        title: webMetadata.title,
        url: webMetadata.url,
      );

  const WebMetadataDto._();

  WebMetadata toDomain() => WebMetadata(
        url: url,
        title: title,
        icon: icon,
      );
}
