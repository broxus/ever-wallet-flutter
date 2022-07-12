import 'package:ever_wallet/application/main/browser/add_bookmark_dialog/add_bookmark_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Future<void> showAddBookmarkDialog({
  required BuildContext context,
  required String title,
  String? name,
  String? url,
  required void Function({
    required String name,
    required String url,
  })
      onSubmit,
}) =>
    showPlatformDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AddBookmarkDialog(
        title: title,
        name: name,
        url: url,
        onSubmit: onSubmit,
      ),
    );
