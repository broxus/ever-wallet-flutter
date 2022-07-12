import 'package:ever_wallet/data/sources/local/hive/dto/meta.dart';
import 'package:hive/hive.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'symbol_dto.freezed.dart';
part 'symbol_dto.g.dart';

@freezedDto
class SymbolDto with _$SymbolDto {
  @HiveType(typeId: 22)
  const factory SymbolDto({
    @HiveField(0) required String name,
    @HiveField(1) required String fullName,
    @HiveField(2) required int decimals,
    @HiveField(3) required String rootTokenContract,
  }) = _SymbolDto;
}

extension SymbolX on Symbol {
  SymbolDto toDto() => SymbolDto(
        name: name,
        fullName: fullName,
        decimals: decimals,
        rootTokenContract: rootTokenContract,
      );
}

extension SymbolDtoX on SymbolDto {
  Symbol toModel() => Symbol(
        name: name,
        fullName: fullName,
        decimals: decimals,
        rootTokenContract: rootTokenContract,
      );
}
