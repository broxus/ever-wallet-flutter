import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'gen_timings_dto.freezed.dart';
part 'gen_timings_dto.g.dart';

@freezed
class GenTimingsDto with _$GenTimingsDto {
  @HiveType(typeId: 5)
  const factory GenTimingsDto({
    @HiveField(0) required String genLt,
    @HiveField(1) required int genUtime,
  }) = _GenTimingsDto;

  factory GenTimingsDto.fromJson(Map<String, dynamic> json) => _$GenTimingsDtoFromJson(json);
}

extension GenTimingsDtoToDomain on GenTimingsDto {
  GenTimings toModel() => GenTimings(
        genLt: genLt,
        genUtime: genUtime,
      );
}

extension GenTimingsFromDomain on GenTimings {
  GenTimingsDto toDto() => GenTimingsDto(
        genLt: genLt,
        genUtime: genUtime,
      );
}
