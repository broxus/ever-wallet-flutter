import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'account.freezed.dart';

@freezed
class Account with _$Account {
  const factory Account.internal({
    required AssetsList assetsList,
  }) = _Internal;

  const factory Account.external({
    required AssetsList assetsList,
  }) = _External;
}
