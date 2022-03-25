import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'bookmark.freezed.dart';
part 'bookmark.g.dart';

@freezed
class Bookmark with _$Bookmark {
  @HiveType(typeId: 3)
  const factory Bookmark({
    @HiveField(0) required String name,
    @HiveField(1) required String url,
  }) = _Bookmark;
}
