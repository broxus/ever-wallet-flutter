import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:validators/validators.dart';

import '../../../../generated/codegen_loader.g.dart';
import '../../../common/widgets/unfocusing_gesture_detector.dart';

class AddBookmarkDialog extends StatefulWidget {
  final String title;
  final String? name;
  final String? url;
  final void Function({
    required String name,
    required String url,
  }) onSubmit;

  const AddBookmarkDialog({
    Key? key,
    required this.title,
    this.name,
    this.url,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AddBookmarkDialog> createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends State<AddBookmarkDialog> {
  late final nameController = TextEditingController(text: widget.name);
  late final urlController = TextEditingController(text: widget.url);

  @override
  void initState() {
    super.initState();
    // nameController.addListener(() => notifier.onNameChange(nameController.text));
    // urlController.addListener(() => notifier.onUrlChange(urlController.text));
  }

  @override
  void dispose() {
    nameController.dispose();
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UnfocusingGestureDetector(
        child: PlatformAlertDialog(
          title: Text(widget.title),
          content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.name.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                PlatformTextField(
                  controller: nameController,
                  autocorrect: false,
                  hintText: '${LocaleKeys.enter_name.tr()}...',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.url.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                PlatformTextField(
                  controller: urlController,
                  autocorrect: false,
                  hintText: '${LocaleKeys.enter_url.tr()}...',
                ),
              ],
            ),
          ),
          actions: [
            PlatformDialogAction(
              onPressed: () => context.router.pop(),
              child: Text(LocaleKeys.cancel.tr()),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: nameController,
              builder: (context, nameValue, child) => ValueListenableBuilder<TextEditingValue>(
                valueListenable: urlController,
                builder: (context, urlValue, child) => PlatformDialogAction(
                  onPressed: nameValue.text.isNotEmpty && urlValue.text.isNotEmpty && isURL(urlValue.text)
                      ? () async {
                          widget.onSubmit(
                            name: nameValue.text,
                            url: urlValue.text,
                          );

                          context.router.pop();
                        }
                      : null,
                  cupertino: (_, __) => CupertinoDialogActionData(
                    isDefaultAction: true,
                  ),
                  child: Text(LocaleKeys.ok.tr()),
                ),
              ),
            ),
          ],
        ),
      );
}
