import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'browser_tabs_dto.freezed.dart';

part 'browser_tabs_dto.g.dart';

@freezed
class BrowserTabsDto with _$BrowserTabsDto {
  @HiveType(typeId: 54)
  const factory BrowserTabsDto({
    // -1 means home page
    @HiveField(0, defaultValue: -1) required int lastActiveTabIndex,
    @HiveField(1, defaultValue: <BrowserTab>[]) required List<BrowserTab> tabs,
  }) = _BrowserTabsDto;
}

@freezed
class BrowserTab with _$BrowserTab {
  @HiveType(typeId: 55)
  const factory BrowserTab({
    @HiveField(0) required String url,
    @HiveField(1) required String? image,
    @HiveField(2) required String? title,
  }) = _BrowserTab;
}
