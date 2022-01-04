import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'token_contract_asset_dto.freezed.dart';
part 'token_contract_asset_dto.g.dart';

@freezed
class TokenContractAssetDto with _$TokenContractAssetDto {
  @HiveType(typeId: 1)
  const factory TokenContractAssetDto({
    @HiveField(0) required String name,
    @HiveField(1) int? chainId,
    @HiveField(2) required String symbol,
    @HiveField(3) required int decimals,
    @HiveField(4) required String address,
    @HiveField(5) String? icon,
    @HiveField(6) required int version,
  }) = _TokenContractAssetDto;

  factory TokenContractAssetDto.fromJson(Map<String, dynamic> json) => _$TokenContractAssetDtoFromJson(json);
}

// // GENERATED CODE - DO NOT MODIFY BY HAND

// part of 'token_contract_asset_dto.dart';

// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************

// class TokenContractAssetDtoAdapter
//     extends TypeAdapter<_$_TokenContractAssetDto> {
//   @override
//   final int typeId = 1;

//   @override
//   _$_TokenContractAssetDto read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return _$_TokenContractAssetDto(
//       name: fields[0] as String,
//       chainId: fields[1] as int?,
//       symbol: fields[2] as String,
//       decimals: fields[3] as int,
//       address: fields[4] as String,
//       icon: fields[5] as String?,
//       version: fields[6] as int,
//     );
//   }

//   @override
//   void write(BinaryWriter writer, _$_TokenContractAssetDto obj) {
//     writer
//       ..writeByte(7)
//       ..writeByte(0)
//       ..write(obj.name)
//       ..writeByte(1)
//       ..write(obj.chainId)
//       ..writeByte(2)
//       ..write(obj.symbol)
//       ..writeByte(3)
//       ..write(obj.decimals)
//       ..writeByte(4)
//       ..write(obj.address)
//       ..writeByte(5)
//       ..write(obj.icon)
//       ..writeByte(6)
//       ..write(obj.version);
//   }

//   @override
//   int get hashCode => typeId.hashCode;

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is TokenContractAssetDtoAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }

// // **************************************************************************
// // JsonSerializableGenerator
// // **************************************************************************

// _$_TokenContractAssetDto _$$_TokenContractAssetDtoFromJson(
//         Map<String, dynamic> json) =>
//     _$_TokenContractAssetDto(
//       name: json['name'] as String,
//       chainId: json['chainId'] as int?,
//       symbol: json['symbol'] as String,
//       decimals: json['decimals'] as int,
//       address: json['address'] as String,
//       icon: json['icon'] as String?,
//       version: json['version'] as int,
//     );

// Map<String, dynamic> _$$_TokenContractAssetDtoToJson(
//         _$_TokenContractAssetDto instance) =>
//     <String, dynamic>{
//       'name': instance.name,
//       'chainId': instance.chainId,
//       'symbol': instance.symbol,
//       'decimals': instance.decimals,
//       'address': instance.address,
//       'icon': instance.icon,
//       'version': instance.version,
//     };
