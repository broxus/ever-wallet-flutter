import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'search_history_dto.freezed.dart';

part 'search_history_dto.g.dart';

/// Title and image are taken via SiteMetaData with SitesMetaDataRepository
@freezed
@HiveType(typeId: 56)
class SearchHistoryDto with _$SearchHistoryDto {
  const factory SearchHistoryDto({
    @HiveField(0) required String url,
    @HiveField(1) required DateTime openTime,
  }) = _SearchHistoryDto;
}
