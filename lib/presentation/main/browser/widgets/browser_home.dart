import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/bookmark.dart';
import '../../../../data/repositories/bookmarks_repository.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../injection.dart';
import '../../../../providers/common/bookmarks_provider.dart';
import '../../../../providers/common/site_meta_data_provider.dart';
import '../../../common/theme.dart';
import '../../../common/widgets/custom_icon_button.dart';
import '../custom_in_app_web_view_controller.dart';
import '../show_confirm_remove_bookmark_dialog.dart';

class BrowserHome extends StatefulWidget {
  final Completer<CustomInAppWebViewController> controller;

  const BrowserHome({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<BrowserHome> createState() => _BrowserHomeState();
}

class _BrowserHomeState extends State<BrowserHome> {
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: CrystalColor.background,
        child: Consumer(
          builder: (context, ref, child) {
            final bookmarks = ref.watch(bookmarksProvider).maybeWhen(
                  data: (data) => data,
                  orElse: () => <Bookmark>[],
                );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(32, 32, 32, 16),
                  child: Text(
                    'Favorites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      letterSpacing: 0.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: bookmarks.isNotEmpty
                      ? list(
                          bookmarks: bookmarks,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: card(
                            child: placeholder(),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      );

  Widget placeholder() => const Center(
        child: Text(
          'There will be your favorites',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 0.25,
          ),
        ),
      );

  Widget list({
    required List<Bookmark> bookmarks,
  }) =>
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              for (final e in bookmarks.map((e) => tile(key: ValueKey(e), bookmark: e)).toList()) ...[
                e,
                const SizedBox(height: 16),
              ]
            ],
          ),
        ),
      );

  Widget tile({
    required Key key,
    required Bookmark bookmark,
  }) =>
      Consumer(
        key: key,
        builder: (context, ref, child) {
          final meta = ref.watch(siteMetaDataProvider(bookmark.url)).asData?.value;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.controller.future.then((v) => v.parseAndLoadUrl(bookmark.url)),
              child: card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              bookmark.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                letterSpacing: 0.25,
                              ),
                            ),
                          ),
                          CustomIconButton(
                            onPressed: () async {
                              final result = await showConfirmRemoveBookmarkDialog(context: context);

                              if (!(result ?? false)) return;

                              getIt.get<BookmarksRepository>().removeBookmark(bookmark.url);
                            },
                            icon: Assets.images.iconCross.svg(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bookmark.url,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (meta?.title != null) ...[
                        Text(
                          meta!.title!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (meta?.description != null) ...[
                        Text(
                          meta!.description!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (meta?.image != null)
                        Image.network(
                          meta!.image!,
                          height: 150,
                          errorBuilder: (context, exception, stackTrace) => const SizedBox(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget card({
    required Widget child,
  }) =>
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
        ),
        child: child,
      );
}
