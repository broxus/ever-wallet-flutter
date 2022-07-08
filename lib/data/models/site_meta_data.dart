import 'package:freezed_annotation/freezed_annotation.dart';

part 'site_meta_data.freezed.dart';

@freezed
class SiteMetaData with _$SiteMetaData {
  const factory SiteMetaData({
    required String url,
    String? title,
    String? image,
    String? description,
  }) = _SiteMetaData;
}
