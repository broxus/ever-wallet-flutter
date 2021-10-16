import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/blocs/misc/bookmarks_bloc.dart';
import '../../../../domain/models/bookmark.dart';
import '../../../design/design.dart';
import 'sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';

class BrowserHomePage extends StatefulWidget {
  final BookmarksBloc bookmarksBloc;
  final void Function(String url) onBookmarkTapped;

  const BrowserHomePage({
    Key? key,
    required this.bookmarksBloc,
    required this.onBookmarkTapped,
  }) : super(key: key);

  @override
  _BrowserHomePageState createState() => _BrowserHomePageState();
}

class _BrowserHomePageState extends State<BrowserHomePage> {
  final isManagingNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    isManagingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.browser_bookmarks.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isManagingNotifier,
                  builder: (context, value, child) => CupertinoButton(
                    onPressed: () => isManagingNotifier.value = !isManagingNotifier.value,
                    child: Text(!value ? LocaleKeys.browser_manage.tr() : LocaleKeys.browser_done.tr()),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<BookmarksBloc, List<Bookmark>>(
              bloc: widget.bookmarksBloc,
              builder: (context, state) => state.isNotEmpty ? buildBookmarks(state) : buildBookmarksPlaceholder(),
            ),
          ),
        ],
      );

  Widget buildBookmarksPlaceholder() => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(
              CupertinoIcons.bookmark,
              size: 64,
            ),
          ),
          Text(
            LocaleKeys.browser_show_bookmarks.tr(),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      );

  Widget buildBookmarks(List<Bookmark> bookmarks) => GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          height: 44,
        ),
        itemCount: bookmarks.length,
        itemBuilder: (context, index) => GridTile(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => widget.onBookmarkTapped(bookmarks[index].url),
                  child: Row(
                    children: [
                      buildBookmarkIcon(
                        bookmarks: bookmarks,
                        index: index,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: buildBookmarkTitle(
                            bookmarks: bookmarks,
                            index: index,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              buildRemoveBookmarkButton(
                bookmarks: bookmarks,
                index: index,
              ),
            ],
          ),
        ),
      );

  Widget buildBookmarkIcon({
    required List<Bookmark> bookmarks,
    required int index,
  }) =>
      bookmarks[index].icon != null && !bookmarks[index].icon!.contains("svg")
          ? SizedBox.square(
              dimension: 22,
              child: Image.network(bookmarks[index].icon!),
            )
          : const Icon(
              CupertinoIcons.globe,
              size: 22,
            );

  Widget buildBookmarkTitle({
    required List<Bookmark> bookmarks,
    required int index,
  }) =>
      Text(
        bookmarks[index].title ?? bookmarks[index].url,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.black,
        ),
      );

  Widget buildRemoveBookmarkButton({
    required List<Bookmark> bookmarks,
    required int index,
  }) =>
      ValueListenableBuilder<bool>(
        valueListenable: isManagingNotifier,
        builder: (context, value, child) => CupertinoButton(
          onPressed: () => showBookmarkRemoveDialog(bookmarks[index]),
          padding: EdgeInsets.zero,
          child: value
              ? const Icon(
                  CupertinoIcons.delete,
                  color: Colors.red,
                )
              : const SizedBox.shrink(),
        ),
      );

  void showBookmarkRemoveDialog(Bookmark bookmark) => showCupertinoDialog(
        context: context,
        builder: (context) => Theme(
          data: ThemeData(),
          child: CupertinoAlertDialog(
            title: Text(LocaleKeys.browser_remove_from_bookmarks.tr()),
            content: Text(LocaleKeys.browser_remove_from_bookmarks_confirm.tr(args: [bookmark.title ?? bookmark.url])),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: Navigator.of(context).pop,
                child: Text(LocaleKeys.browser_cancel.tr()),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  widget.bookmarksBloc.add(BookmarksEvent.removeBookmark(bookmark));
                  Navigator.of(context).pop();
                },
                textStyle: const TextStyle(
                  color: Colors.red,
                ),
                child: Text(
                  LocaleKeys.browser_remove.tr(),
                ),
              ),
            ],
          ),
        ),
      );
}
