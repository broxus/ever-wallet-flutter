import 'package:freezed_annotation/freezed_annotation.dart';

const freezedDto = Freezed(
  copyWith: false,
  equal: false,
  toStringOverride: false,
  fromJson: false,
  toJson: false,
);
