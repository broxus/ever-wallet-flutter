import 'dart:async';

import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/custom_popup_item.dart';
import 'package:ever_wallet/application/common/widgets/custom_popup_menu.dart';
import 'package:ever_wallet/application/common/widgets/custom_text_form_field.dart';
import 'package:ever_wallet/application/common/widgets/suffix_loader_icon.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/main/browser/add_bookmark_dialog/show_add_bookmark_dialog.dart';
import 'package:ever_wallet/application/main/browser/back_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/forward_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/progress_cubit.dart';
import 'package:ever_wallet/application/main/browser/url_cubit.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_icon_button.dart';
import 'package:ever_wallet/data/repositories/bookmarks_repository.dart';
import 'package:ever_wallet/data/repositories/search_history_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:validators/validators.dart';

class BrowserAppBar extends StatefulWidget {
  final Completer<InAppWebViewController> controller;
  final TextEditingController urlController;
  final FocusNode urlFocusNode;

  const BrowserAppBar({
    Key? key,
    required this.controller,
    required this.urlController,
    required this.urlFocusNode,
  }) : super(key: key);

  @override
  State<BrowserAppBar> createState() => _BrowserAppBarState();
}

class _BrowserAppBarState extends State<BrowserAppBar> {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            leading(),
            Expanded(
              child: field(),
            ),
            trailing(),
          ],
        ),
      );

  Widget leading() => AnimatedBuilder(
        animation: widget.urlFocusNode,
        builder: (context, child) => !widget.urlFocusNode.hasFocus
            ? Row(
                children: [
                  back(),
                  forward(),
                ],
              )
            : const Gap(8),
      );

  Widget back() => BlocBuilder<BackButtonEnabledCubit, bool>(
        builder: (context, state) {
          final backButtonEnabled = state;

          return BrowserIconButton(
            onPressed:
                backButtonEnabled ? () => widget.controller.future.then((v) => v.goBack()) : null,
            icon: PlatformIcons(context).back,
          );
        },
      );

  Widget forward() => BlocBuilder<ForwardButtonEnabledCubit, bool>(
        builder: (context, state) {
          final forwardButtonEnabled = state;

          return BrowserIconButton(
            onPressed: forwardButtonEnabled
                ? () => widget.controller.future.then((v) => v.goForward())
                : null,
            icon: PlatformIcons(context).forward,
          );
        },
      );

  Widget field() => ColoredBox(
        color: Colors.white,
        child: AnimatedBuilder(
          animation: widget.urlFocusNode,
          builder: (context, child) => BlocBuilder<ProgressCubit, int>(
            builder: (context, state) {
              final progress = state;

              Widget? suffixIcon;

              if (progress != 100) {
                suffixIcon = const SuffixLoaderIcon();
              } else if (widget.urlFocusNode.hasFocus) {
                suffixIcon = TextFieldClearButton(controller: widget.urlController);
              }

              return CustomTextFormField(
                name: AppLocalizations.of(context)!.url,
                controller: widget.urlController,
                focusNode: widget.urlFocusNode,
                autocorrect: false,
                hintText: AppLocalizations.of(context)!.address_field_placeholder,
                onSubmitted: (value) {
                  if (value == null || value.trim().isEmpty) return;

                  context.read<SearchHistoryRepository>().addSearchHistoryEntry(value);

                  widget.controller.future.then((v) => v.tryLoadUrl(value));
                },
                suffixIcon: suffixIcon,
              );
            },
          ),
        ),
      );

  Widget trailing() => AnimatedBuilder(
        animation: widget.urlFocusNode,
        builder: (context, child) => !widget.urlFocusNode.hasFocus
            ? Row(
                children: [
                  home(),
                  menu(),
                ],
              )
            : const Gap(8),
      );

  Widget home() => BrowserIconButton(
        onPressed: () => widget.controller.future.then((v) => v.goHome()),
        icon: PlatformIcons(context).home,
      );

  Widget menu() => BlocBuilder<UrlCubit, Uri?>(
        builder: (context, state) {
          final url = state;

          return CustomPopupMenu(
            items: [
              reload(),
              if (isURL(url.toString())) ...[
                share(),
                addBookmark(),
              ]
            ],
            icon: Icon(
              PlatformIcons(context).ellipsis,
              color: CrystalColor.accent,
            ),
          );
        },
      );

  CustomPopupItem reload() => CustomPopupItem(
        title: Text(
          AppLocalizations.of(context)!.reload,
          style: const TextStyle(fontSize: 16),
        ),
        onTap: () => widget.controller.future.then((v) => v.reload()),
      );

  CustomPopupItem share() => CustomPopupItem(
        title: Text(
          AppLocalizations.of(context)!.share,
          style: const TextStyle(fontSize: 16),
        ),
        onTap: () async {
          final url = await widget.controller.future.then((v) => v.getUrl());

          if (url == null) return;

          Share.share(url.toString());
        },
      );

  CustomPopupItem addBookmark() => CustomPopupItem(
        title: Text(
          AppLocalizations.of(context)!.add_bookmark,
          style: const TextStyle(fontSize: 16),
        ),
        onTap: () async {
          final url = await widget.controller.future.then((v) => v.getUrl());

          if (!mounted) return;

          showAddBookmarkDialog(
            context: context,
            title: AppLocalizations.of(context)!.add_bookmark,
            name: url?.authority,
            url: url?.toString(),
            onSubmit: ({
              required String name,
              required String url,
            }) =>
                context.read<BookmarksRepository>().addBookmark(
                      name: name,
                      url: url,
                    ),
          );
        },
      );
}
