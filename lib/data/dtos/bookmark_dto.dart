import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../../domain/models/bookmark.dart';

part 'bookmark_dto.freezed.dart';
part 'bookmark_dto.g.dart';

@freezed
@HiveType(typeId: 0)
class BookmarkDto with _$BookmarkDto {
  const factory BookmarkDto({
    @HiveField(0) required String url,
    @HiveField(1) String? title,
    @HiveField(2) String? icon,
  }) = _BookmarkDto;

  factory BookmarkDto.fromDomain(Bookmark bookmark) => BookmarkDto(
        url: bookmark.url,
        title: bookmark.title,
        icon: bookmark.icon,
      );

  const BookmarkDto._();

  Bookmark toDomain() => Bookmark(
        url: url,
        title: title,
        icon: icon,
      );
}
