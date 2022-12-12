import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/general/button/primary_icon_button.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/default_list_tile.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_search_field.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/page_routes.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/application/utils.dart';
import 'package:ever_wallet/data/models/search_history_dto.dart';
import 'package:ever_wallet/data/repositories/search_history_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:favicon/favicon.dart' as fav;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

class BrowserSearchRoute extends NoAnimationPageRoute<void> {
  BrowserSearchRoute(
    String initUrl,
    ValueChanged<String> changeUrl,
  ) : super(
          builder: (_) => BrowserSearchScreen(
            initUrl: initUrl,
            changeUrl: changeUrl,
          ),
        );
}

class BrowserSearchScreen extends StatefulWidget {
  final String initUrl;
  final ValueChanged<String> changeUrl;

  const BrowserSearchScreen({
    required this.initUrl,
    required this.changeUrl,
    super.key,
  });

  @override
  State<BrowserSearchScreen> createState() => _BrowserSearchScreenState();
}

class _BrowserSearchScreenState extends State<BrowserSearchScreen> {
  final urlFocusNode = FocusNode();
  final controller = TextEditingController();

  @override
  void initState() {
    urlFocusNode.requestFocus();
    controller.value = TextEditingValue(
      text: widget.initUrl,
      selection: TextSelection(
        baseOffset: 0,
        extentOffset: widget.initUrl.length,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    urlFocusNode.dispose();
    super.dispose();
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
                child: BrowserSearchHistory(changeUrl: widget.changeUrl),
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
    final suffixIcon = TextFieldClearButton(
      focus: urlFocusNode,
      controller: controller,
      iconColor: ColorsRes.bluePrimary400,
    );

    return BrowserSearchField(
      controller: controller,
      focus: urlFocusNode,
      hintText: context.localization.address_field_placeholder,
      onSubmitted: (value) {
        if (value.trim().isEmpty) {
          _closeSearch(context);
          return;
        }

        widget.changeUrl(value);
        _closeSearch(context);
      },
      suffixIcon: suffixIcon,
    );
  }

  void _closeSearch(BuildContext context) {
    urlFocusNode.unfocus();
    Navigator.of(context).pop();
  }
}

class BrowserSearchHistory extends StatelessWidget {
  final ValueChanged<String> changeUrl;

  const BrowserSearchHistory({
    required this.changeUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) => StreamProvider<AsyncValue<List<SearchHistoryDto>>>(
        create: (context) => context
            .read<SearchHistoryRepository>()
            .searchHistoryStream
            .map((event) => AsyncValue.ready(event)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, child) {
          final searchHistory = context
              .watch<AsyncValue<List<SearchHistoryDto>>>()
              .maybeWhen(
                ready: (value) => value,
                orElse: () => <SearchHistoryDto>[],
              )
              .reversed
              .take(10);

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
                              onPressed: () => changeUrl(clip.data!.text!),
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
                  searchHistory.map((e) => tile(context: context, entry: e)).toList(),
                ),
              ),
            ],
          );
        },
      );

  Widget tile({
    required BuildContext context,
    required SearchHistoryDto entry,
  }) {
    final isUrl = isURL(entry.url);
    return EWListTile(
      onPressed: () {
        if (isUrl) {
          changeUrl(entry.url);
        } else {
          changeUrl(getDuckDuckGoSearchLink(entry.url));
        }
        Navigator.of(context).pop();
      },
      leading: !isUrl
          ? Assets.images.iconSearch.svg(width: 24, height: 24)
          : FutureBuilder<fav.Favicon?>(
              future: fav.FaviconFinder.getBest(entry.url),
              builder: (context, icon) {
                if (icon.data?.url != null) {
                  final image = icon.data!.url;
                  return CircleAvatar(
                    maxRadius: 13,
                    child: image.endsWith('svg')
                        ? SvgPicture.network(image, width: 24, height: 24)
                        : Image.network(
                            icon.data!.url,
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                          ),
                  );
                }
                return Assets.images.browser.iconGlobe.svg(width: 24, height: 24);
              },
            ),
      titleWidget: Text(
        entry.url.overflow,
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
