import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'browser_tabs_dto.freezed.dart';

part 'browser_tabs_dto.g.dart';

@freezed
@HiveType(typeId: 55)
class BrowserTab with _$BrowserTab {
  const factory BrowserTab({
    @HiveField(0) required String url,
    @HiveField(1) required String? image,
    @HiveField(2) required String? title,
    @HiveField(3, defaultValue: 0) required int lastScrollPosition,
    @HiveField(4) Uint8List? screenshot,
  }) = _BrowserTab;
}
