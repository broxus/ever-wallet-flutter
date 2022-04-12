import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'currency.freezed.dart';
part 'currency.g.dart';

@freezed
class Currency with _$Currency {
  @HiveType(typeId: 4)
  const factory Currency({
    @HiveField(0) required String currency,
    @HiveField(1) required String address,
    @HiveField(2) required String price,
    @HiveField(3) required String priceChange,
    @HiveField(4) required String tvl,
    @HiveField(5) required String tvlChange,
    @HiveField(6) required String volume24h,
    @HiveField(7) required String volumeChange24h,
    @HiveField(8) required String volume7d,
    @HiveField(9) required String fee24h,
    @HiveField(10) required int transactionsCount24h,
  }) = _Currency;

  factory Currency.fromJson(Map<String, dynamic> json) => _$CurrencyFromJson(json);
}
