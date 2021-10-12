import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark.freezed.dart';

@freezed
class Bookmark with _$Bookmark {
  const factory Bookmark({
    required String url,
    String? title,
    String? icon,
  }) = _Bookmark;
}
