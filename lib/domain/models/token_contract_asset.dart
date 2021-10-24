import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'token_contract_asset.freezed.dart';

@freezed
class TokenContractAsset with _$TokenContractAsset {
  const factory TokenContractAsset({
    required String name,
    int? chainId,
    required String symbol,
    required int decimals,
    required String address,
    String? logoURI,
    required int version,
  }) = _TokenContractAsset;

  factory TokenContractAsset.fromTokenWallet(TokenWallet tokenWallet) => TokenContractAsset(
        name: tokenWallet.symbol.fullName,
        symbol: tokenWallet.symbol.name,
        decimals: tokenWallet.symbol.decimals,
        address: tokenWallet.symbol.rootTokenContract,
        version: tokenWallet.version.index + 1,
      );
}
