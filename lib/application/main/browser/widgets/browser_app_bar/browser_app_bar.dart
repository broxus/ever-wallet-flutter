import 'dart:async';

import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/default_list_tile.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/main/browser/back_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/browser_history/browser_history_screen.dart';
import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tabs_cubit/browser_tabs_cubit.dart';
import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/forward_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/progress_cubit.dart';
import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_app_bar/browser_app_bar_scroll_listener.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_icon_button.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_search_history.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/data/repositories/bookmarks_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';

/// Appbar without editing url
class BrowserAppBar extends StatefulWidget {
  final Completer<InAppWebViewController> controller;
  final TextEditingController urlController;
  final BrowserTabsCubit tabsCubit;
  final ValueChanged<String> changeUrl;
  final int tabsCount;

  const BrowserAppBar({
    required this.urlController,
    required this.tabsCubit,
    required this.changeUrl,
    required this.tabsCount,
    required this.controller,
    super.key,
  });

  @override
  State<BrowserAppBar> createState() => _BrowserAppBarState();
}

class _BrowserAppBarState extends State<BrowserAppBar> {
  @override
  Widget build(BuildContext context) => Container(
        color: ColorsRes.white,
        height: BrowserAppBarScrollListener.appBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Row(
                children: [
                  leading(),
                  Expanded(child: field()),
                  const SizedBox(width: 4),
                  trailing(),
                ],
              ),
              const SizedBox(height: 6),
              BlocBuilder<ProgressCubit, int>(
                builder: (context, state) {
                  if (state == 0 || state == 100) return const SizedBox(height: 2);
                  return SizedBox(
                    height: 2,
                    child: LinearProgressIndicator(
                      color: ColorsRes.bluePrimary400,
                      value: state / 100,
                    ),
                  );
                },
              ),
              const DefaultDivider(),
            ],
          ),
        ),
      );

  Widget leading() => Row(
        children: [
          back(),
          forward(),
        ],
      );

  Widget back() => BlocBuilder<BackButtonEnabledCubit, bool>(
        builder: (context, state) {
          final backButtonEnabled = state;

          return BrowserIconButton(
            onPressed:
                backButtonEnabled ? () => widget.controller.future.then((v) => v.goBack()) : null,
            icon: Icons.arrow_back_ios_new_rounded,
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
            icon: Icons.arrow_forward_ios_rounded,
          );
        },
      );

  Widget field() => ValueListenableBuilder<TextEditingValue>(
        valueListenable: widget.urlController,
        builder: (context, value, __) {
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              BrowserSearchRoute(widget.urlController.text, widget.changeUrl),
            ),
            child: Container(
              height: 48,
              alignment: Alignment.centerLeft,
              color: ColorsRes.neutral750,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                value.text.isEmpty
                    ? context.localization.address_field_placeholder
                    : Uri.parse(value.text).host,
                style: StylesRes.basicText.copyWith(
                  color: value.text.isEmpty ? ColorsRes.neutral500 : ColorsRes.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      );

  Widget trailing() => Row(
        children: [
          tabs(),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.urlController,
            builder: (context, url, __) {
              if (url.text.isEmpty || url.text == aboutBlankPage) {
                return history();
              }
              return menu(context);
            },
          ),
        ],
      );

  Widget tabs() {
    return BlocBuilder<BrowserTabsCubit, BrowserTabsCubitState>(
      bloc: widget.tabsCubit,
      builder: (_, state) {
        return BrowserIconButton(
          onPressed: () => widget.tabsCubit.showTabs(),
          child: Container(
            width: 20,
            height: 20,
            padding: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(width: 2, color: ColorsRes.bluePrimary400),
            ),
            child: Center(
              child: Text(
                '${state.tabs.tabs.length}',
                style: StylesRes.subtitleStyle.copyWith(
                  color: ColorsRes.bluePrimary400,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget history() {
    return BrowserIconButton(
      onPressed: () => Navigator.of(context).push(BrowserHistoryRoute(widget.changeUrl)),
      child: Assets.images.history.svg(width: 20, height: 20),
    );
  }

  Widget menu(BuildContext context) {
    return BrowserIconButton(
      onPressed: () {
        showEWBottomSheet<void>(
          context,
          needCloseButton: false,
          body: _menuBody,
        );
      },
      child: const Icon(
        Icons.more_horiz,
        color: ColorsRes.bluePrimary400,
        size: 20,
      ),
    );
  }

  Widget _menuBody(BuildContext sheetContext) {
    final localization = sheetContext.localization;
    // ignore: prefer_function_declarations_over_variables
    final closeSheet = () => Navigator.of(sheetContext).pop();
    final currentTab = widget.tabsCubit.tabs[widget.tabsCubit.activeTabIndex];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // EWListTile(
        //   // TODO: implement changing accounts
        //   onPressed: () {},
        //   leading: Assets.images.wallet.svg(color: ColorsRes.bluePrimary400),
        //   titleWidget: Text(
        //     localization.change_account,
        //     style: StylesRes.regular16.copyWith(color: ColorsRes.black),
        //   ),
        // ),
        // const DefaultDivider(),
        EWListTile(
          onPressed: () {
            widget.controller.future.then((c) => c.refresh());
            closeSheet();
          },
          leading: Assets.images.reload.svg(color: ColorsRes.bluePrimary400),
          titleWidget: Text(
            localization.reload,
            style: StylesRes.regular16.copyWith(color: ColorsRes.black),
          ),
        ),
        const DefaultDivider(),
        EWListTile(
          onPressed: () {
            closeSheet();
            Share.share(currentTab.url);
          },
          leading: Assets.images.share.svg(color: ColorsRes.bluePrimary400),
          titleWidget: Text(
            localization.share,
            style: StylesRes.regular16.copyWith(color: ColorsRes.black),
          ),
        ),
        const DefaultDivider(),
        EWListTile(
          onPressed: () {
            final repo = sheetContext.read<BookmarksRepository>();
            repo
                .addBookmark(
              name: currentTab.title ?? '',
              url: widget.urlController.text,
            )
                .then((bookmark) {
              closeSheet();
              showFlushbarWithAction(
                context: context,
                text: localization.site_added_to_bookmarks,
                actionText: localization.undo,
                action: () => repo.deleteBookmark(bookmark.id),
              );
            });
          },
          leading: Assets.images.browser.star.svg(color: ColorsRes.bluePrimary400),
          titleWidget: Text(
            localization.add_to_bookmarks,
            style: StylesRes.regular16.copyWith(color: ColorsRes.black),
          ),
        ),
        const DefaultDivider(),
        EWListTile(
          onPressed: () => Navigator.of(sheetContext).pushReplacement(
            BrowserHistoryRoute(widget.changeUrl),
          ),
          leading: Assets.images.history.svg(color: ColorsRes.bluePrimary400),
          titleWidget: Text(
            localization.history,
            style: StylesRes.regular16.copyWith(color: ColorsRes.black),
          ),
        ),
        const DefaultDivider(),
      ],
    );
  }
}
