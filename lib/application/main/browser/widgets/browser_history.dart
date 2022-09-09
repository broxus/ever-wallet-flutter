import 'dart:async';

import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/general/button/primary_icon_button.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/default_list_tile.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/main/browser/url_cubit.dart';
import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_search_field.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/page_routes.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/application/utils.dart';
import 'package:ever_wallet/data/repositories/search_history_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:favicon/favicon.dart' as fav;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

class BrowserSearchRoute extends NoAnimationPageRoute<void> {
  BrowserSearchRoute(
    Completer<InAppWebViewController> controller,
    FocusNode urlFocusNode,
    TextEditingController urlController,
    UrlCubit urlCubit,
  ) : super(
          builder: (_) => BrowserSearchScreen(
            controller: controller,
            urlFocusNode: urlFocusNode,
            urlController: urlController,
            urlCubit: urlCubit,
          ),
        );
}

class BrowserSearchScreen extends StatefulWidget {
  final Completer<InAppWebViewController> controller;
  final FocusNode urlFocusNode;
  final TextEditingController urlController;
  final UrlCubit urlCubit;

  const BrowserSearchScreen({
    required this.controller,
    required this.urlFocusNode,
    required this.urlController,
    required this.urlCubit,
    Key? key,
  }) : super(key: key);

  @override
  State<BrowserSearchScreen> createState() => _BrowserSearchScreenState();
}

class _BrowserSearchScreenState extends State<BrowserSearchScreen> {
  @override
  void initState() {
    widget.urlFocusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _searchBar(context),
            Expanded(
              child: GestureDetector(
                onTap: () => _closeSearch(context),
                child: BrowserSearchHistory(
                  controller: widget.controller,
                  urlFocusNode: widget.urlFocusNode,
                  urlCubit: widget.urlCubit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return ColoredBox(
      color: ColorsRes.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(child: _field(context)),
                const SizedBox(width: 4),
                TextPrimaryButton(
                  text: context.localization.cancel,
                  style: context.themeStyle.styles.primaryButtonStyle.copyWith(
                    color: ColorsRes.bluePrimary400,
                  ),
                  padding: const EdgeInsets.all(16),
                  fillWidth: false,
                  onPressed: () => _closeSearch(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const DefaultDivider(),
          ],
        ),
      ),
    );
  }

  Widget _field(BuildContext context) {
    final suffixIcon = ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.urlController,
      builder: (_, value, ___) {
        if (value.text.isEmpty) return const SizedBox.shrink();

        return TextFieldClearButton(
          focus: widget.urlFocusNode,
          controller: widget.urlController,
          iconColor: ColorsRes.bluePrimary400,
        );
      },
    );

    return BrowserSearchField(
      controller: widget.urlController,
      focus: widget.urlFocusNode,
      hintText: context.localization.address_field_placeholder,
      onSubmitted: (value) {
        if (value.trim().isEmpty) {
          _closeSearch(context);
          return;
        }

        context.read<SearchHistoryRepository>().addSearchHistoryEntry(value);

        widget.urlCubit.setUrl(value);
        _closeSearch(context);
      },
      suffixIcon: suffixIcon,
    );
  }

  void _closeSearch(BuildContext context) {
    widget.urlFocusNode.unfocus();
    Navigator.of(context).pop();
  }
}

class BrowserSearchHistory extends StatelessWidget {
  final Completer<InAppWebViewController> controller;
  final FocusNode urlFocusNode;
  final UrlCubit urlCubit;

  const BrowserSearchHistory({
    Key? key,
    required this.controller,
    required this.urlFocusNode,
    required this.urlCubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamProvider<AsyncValue<List<String>>>(
        create: (context) => context
            .read<SearchHistoryRepository>()
            .searchHistoryStream
            .map((event) => AsyncValue.ready(event)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, child) {
          final searchHistory = context
              .watch<AsyncValue<List<String>>>()
              .maybeWhen(
                ready: (value) => value,
                orElse: () => <String>[],
              )
              .reversed;

          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: FutureBuilder<bool>(
                  future: Clipboard.hasStrings(),
                  builder: (context, hasClipData) {
                    if (hasClipData.hasData && hasClipData.data!) {
                      return FutureBuilder<ClipboardData?>(
                        future: Clipboard.getData(Clipboard.kTextPlain),
                        builder: (context, clip) {
                          if (clip.data?.text != null && clip.data!.text!.isNotEmpty) {
                            return EWListTile(
                              leading: Assets.images.copy.svg(
                                color: ColorsRes.neutral500,
                                width: 24,
                                height: 24,
                              ),
                              titleWidget: Text(
                                clip.data!.text!.overflow,
                                style: StylesRes.basicText.copyWith(color: ColorsRes.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  searchHistory
                      .map((e) => tile(context: context, key: ValueKey(e), entry: e))
                      .toList(),
                ),
              ),
            ],
          );
        },
      );

  Widget tile({
    required BuildContext context,
    required Key key,
    required String entry,
  }) {
    final uri = Uri.tryParse(entry);
    return EWListTile(
      onPressed: () {
        context.read<SearchHistoryRepository>().addSearchHistoryEntry(entry);

        urlFocusNode.unfocus();

        if (isURL(entry)) {
          urlCubit.setUrl(entry);
        } else {
          urlCubit.setUrl(getDuckDuckGoSearchLink(entry));
        }
        Navigator.of(context).pop();
      },
      leading: uri == null
          ? Assets.images.iconSearch.svg(width: 24, height: 24)
          : FutureBuilder<fav.Icon?>(
              future: fav.Favicon.getBest(uri.toString()),
              builder: (context, icon) {
                if (icon.data?.url != null) {
                  return CircleAvatar(
                    child: Image.network(
                      icon.data!.url,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return Assets.images.browser.iconGlobe.svg(width: 24, height: 24);
              },
            ),
      titleWidget: Text(
        entry.overflow,
        style: StylesRes.basicText.copyWith(color: ColorsRes.black),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PrimaryIconButton(
        onPressed: () => context.read<SearchHistoryRepository>().removeSearchHistoryEntry(entry),
        icon: Assets.images.iconCross.svg(),
      ),
    );
  }
}
