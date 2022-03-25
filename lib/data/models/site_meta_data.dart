import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'site_meta_data.freezed.dart';
part 'site_meta_data.g.dart';

@freezed
class SiteMetaData with _$SiteMetaData {
  @HiveType(typeId: 2)
  const factory SiteMetaData({
    @HiveField(0) required String url,
    @HiveField(1) String? title,
    @HiveField(2) String? image,
    @HiveField(3) String? description,
  }) = _SiteMetaData;
}
