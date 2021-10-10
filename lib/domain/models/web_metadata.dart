import 'package:freezed_annotation/freezed_annotation.dart';

part 'web_metadata.freezed.dart';

@freezed
class WebMetadata with _$WebMetadata {
  const factory WebMetadata({
    required String url,
    String? title,
    String? icon,
  }) = _WebMetadata;
}
