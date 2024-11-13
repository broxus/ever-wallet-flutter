import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_config.freezed.dart';

@freezed
class NetworkConfig with _$NetworkConfig {
  const factory NetworkConfig({
    required String symbol,
    required String explorerBaseUrl,
    required String tokensManifestUrl,
    required String currenciesApiBaseUrl,
  }) = _NetworkConfig;
}
