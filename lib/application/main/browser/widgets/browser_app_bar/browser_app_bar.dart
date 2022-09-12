import 'dart:async';

import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/main/browser/back_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tabs_cubit/browser_tabs_cubit.dart';
import 'package:ever_wallet/application/main/browser/forward_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/progress_cubit.dart';
import 'package:ever_wallet/application/main/browser/url_cubit.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_app_bar/browser_app_bar_scroll_listener.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_icon_button.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_search_history.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Appbar without editing url
class BrowserAppBar extends StatefulWidget {
  final Completer<InAppWebViewController> controller;
  final TextEditingController urlController;
  final FocusNode urlFocusNode;
  final BrowserTabsCubit tabsCubit;

  const BrowserAppBar({
    required this.controller,
    required this.urlController,
    required this.urlFocusNode,
    required this.tabsCubit,
    Key? key,
  }) : super(key: key);

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
                      value: state.toDouble(),
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
              BrowserSearchRoute(
                widget.controller,
                widget.urlFocusNode,
                widget.urlController,
                context.read<UrlCubit>(),
              ),
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
          FutureBuilder<InAppWebViewController>(
            future: widget.controller.future,
            builder: (_, snap) {
              if (snap.hasData) {
                return FutureBuilder<Uri?>(
                  future: snap.data!.getUrl(),
                  builder: (_, uri) {
                    if (uri.hasData && uri.data != null) {
                      return menu();
                    }
                    return history();
                  },
                );
              }
              return history();
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
      onPressed: () {},
      child: Assets.images.history.svg(width: 20, height: 20),
    );
  }

  Widget menu() {
    return BrowserIconButton(
      onPressed: () {},
      child: const Icon(
        Icons.more_horiz,
        color: ColorsRes.bluePrimary400,
        size: 20,
      ),
    );
  }

// Widget home() => BrowserIconButton(
//       onPressed: () => widget.controller.future.then((v) => v.goHome()),
//       icon: PlatformIcons(context).home,
//     );
//
// Widget menu() => BlocBuilder<UrlCubit, Uri?>(
//       builder: (context, state) {
//         final url = state;
//
//         return CustomPopupMenu(
//           items: [
//             reload(),
//             if (isURL(url.toString())) ...[
//               share(),
//               addBookmark(),
//             ]
//           ],
//           icon: Icon(
//             PlatformIcons(context).ellipsis,
//             color: CrystalColor.accent,
//           ),
//         );
//       },
//     );

// CustomPopupItem reload() => CustomPopupItem(
//       title: Text(
//         context.localization.reload,
//         style: const TextStyle(fontSize: 16),
//       ),
//       onTap: () => widget.controller.future.then((v) => v.reload()),
//     );
//
// CustomPopupItem share() => CustomPopupItem(
//       title: Text(
//         context.localization.share,
//         style: const TextStyle(fontSize: 16),
//       ),
//       onTap: () async {
//         final url = await widget.controller.future.then((v) => v.getUrl());
//
//         if (url == null) return;
//
//         Share.share(url.toString());
//       },
//     );
//
// CustomPopupItem addBookmark() => CustomPopupItem(
//       title: Text(
//         context.localization.add_bookmark,
//         style: const TextStyle(fontSize: 16),
//       ),
//       onTap: () async {
//         final url = await widget.controller.future.then((v) => v.getUrl());
//
//         if (!mounted) return;
//
//         showAddBookmarkDialog(
//           context: context,
//           title: context.localization.add_bookmark,
//           name: url?.authority,
//           url: url?.toString(),
//           onSubmit: ({
//             required String name,
//             required String url,
//           }) =>
//               context.read<BookmarksRepository>().addBookmark(
//                     name: name,
//                     url: url,
//                   ),
//         );
//       },
//     );
}
