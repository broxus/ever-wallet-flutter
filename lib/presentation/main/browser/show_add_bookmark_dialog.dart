import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../injection.dart';
import '../../../data/models/bookmark.dart';
import '../../../data/repositories/bookmarks_repository.dart';
import '../../common/widgets/unfocusing_gesture_detector.dart';

Future<void> showAddBookmarkDialog({
  required BuildContext context,
  required Uri url,
}) =>
    showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final nameController = TextEditingController(text: url.authority);
          final urlController = TextEditingController(text: url.toString());

          return UnfocusingGestureDetector(
            child: PlatformAlertDialog(
              title: const Text('Add bookmark'),
              content: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PlatformTextField(
                      controller: nameController,
                      autocorrect: false,
                      hintText: 'Enter name...',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Url',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PlatformTextField(
                      controller: urlController,
                      autocorrect: false,
                      hintText: 'Enter url...',
                    ),
                  ],
                ),
              ),
              actions: [
                PlatformDialogAction(
                  onPressed: () => context.router.pop(),
                  child: const Text('Cancel'),
                ),
                PlatformDialogAction(
                  onPressed: () async {
                    try {
                      final name = nameController.text;
                      final url = urlController.text;

                      if (name.isEmpty || url.isEmpty || Uri.tryParse(url) == null) {
                        context.router.pop();
                        return;
                      }

                      getIt.get<BookmarksRepository>().addBookmark(
                            url: url,
                            bookmark: Bookmark(name: name, url: url),
                          );

                      context.router.pop();
                    } finally {
                      Future.delayed(const Duration(seconds: 3), () {
                        nameController.dispose();
                        urlController.dispose();
                      });
                    }
                  },
                  cupertino: (_, __) => CupertinoDialogActionData(
                    isDefaultAction: true,
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      ),
    );
