import 'package:freezed_annotation/freezed_annotation.dart';

part 'connected_site.freezed.dart';

@freezed
class ConnectedSite with _$ConnectedSite {
  const factory ConnectedSite({
    required String url,
    required DateTime time,
  }) = _ConnectedSite;
}
