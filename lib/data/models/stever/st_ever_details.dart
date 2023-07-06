import 'package:freezed_annotation/freezed_annotation.dart';

part 'st_ever_details.freezed.dart';

part 'st_ever_details.g.dart';

/// This is not full contract info, but only used fields here
@freezed
class StEverDetails with _$StEverDetails {
  const factory StEverDetails({
    required String stEverSupply,
    required String totalAssets,
    // Time before withdrawing in secodns
    required String withdrawHoldTime,
  }) = _StEverDetails;

  factory StEverDetails.fromJson(Map<String, dynamic> json) => _$StEverDetailsFromJson(json);
}
