import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'symbol_dto.freezed.dart';
part 'symbol_dto.g.dart';

@freezed
class SymbolDto with _$SymbolDto {
  @HiveType(typeId: 0)
  const factory SymbolDto({
    @HiveField(0) required String name,
    @HiveField(1) required String fullName,
    @HiveField(2) required int decimals,
    @HiveField(3) required String rootTokenContract,
  }) = _SymbolDto;

  factory SymbolDto.fromJson(Map<String, dynamic> json) => _$SymbolDtoFromJson(json);
}

extension SymbolDtoToDomain on SymbolDto {
  Symbol toModel() => Symbol(
        name: name,
        fullName: fullName,
        decimals: decimals,
        rootTokenContract: rootTokenContract,
      );
}

extension SymbolFromDomain on Symbol {
  SymbolDto toDto() => SymbolDto(
        name: name,
        fullName: fullName,
        decimals: decimals,
        rootTokenContract: rootTokenContract,
      );
}
