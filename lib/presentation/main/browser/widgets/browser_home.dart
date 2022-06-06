import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/bookmark.dart';
import '../../../../data/repositories/bookmarks_repository.dart';
import '../../../../injection.dart';
import '../../../../providers/common/bookmarks_provider.dart';
import '../../../../providers/common/site_meta_data_provider.dart';
import '../../../common/theme.dart';
import '../../../common/widgets/custom_icon_button.dart';
import '../add_bookmark_dialog/show_add_bookmark_dialog.dart';
import '../extensions.dart';
import '../show_confirm_remove_bookmark_dialog.dart';

class BrowserHome extends StatefulWidget {
  final Completer<InAppWebViewController> controller;

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                  child: Text(
                    AppLocalizations.of(context)!.favorites,
                    style: const TextStyle(
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

  Widget placeholder() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            addButton(),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.favorites_placeholder,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 0.25,
              ),
            ),
          ],
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
              ],
              addButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );

  Widget addButton() => Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        child: InkWell(
          onTap: () => showAddBookmarkDialog(
            context: context,
            title: AppLocalizations.of(context)!.add_bookmark,
            onSubmit: ({
              required String name,
              required String url,
            }) =>
                getIt.get<BookmarksRepository>().addBookmark(
                      name: name,
                      url: url,
                    ),
          ),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(
              PlatformIcons(context).add,
              size: 36,
              color: Colors.white,
            ),
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
              onTap: () => widget.controller.future.then((v) => v.tryLoadUrl(bookmark.url)),
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
                            onPressed: () async => showAddBookmarkDialog(
                              context: context,
                              title: AppLocalizations.of(context)!.edit_bookmark,
                              name: bookmark.name,
                              url: bookmark.url,
                              onSubmit: ({
                                required String name,
                                required String url,
                              }) =>
                                  getIt.get<BookmarksRepository>().editBookmark(
                                        id: bookmark.id,
                                        newName: name,
                                        newUrl: url,
                                      ),
                            ),
                            icon: Icon(
                              PlatformIcons(context).edit,
                              color: Colors.white,
                            ),
                          ),
                          CustomIconButton(
                            onPressed: () async {
                              final result = await showConfirmRemoveBookmarkDialog(context: context);

                              if (!(result ?? false)) return;

                              getIt.get<BookmarksRepository>().deleteBookmark(bookmark.id);
                            },
                            icon: Icon(
                              PlatformIcons(context).clear,
                              color: Colors.white,
                            ),
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
