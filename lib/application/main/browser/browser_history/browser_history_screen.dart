import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/default_list_tile.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_search_field.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/extensions/iterable_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/application/utils.dart';
import 'package:ever_wallet/data/models/search_history_dto.dart';
import 'package:ever_wallet/data/models/site_meta_data.dart';
import 'package:ever_wallet/data/repositories/search_history_repository.dart';
import 'package:ever_wallet/data/repositories/sites_meta_data_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

class BrowserHistoryRoute extends MaterialPageRoute<void> {
  BrowserHistoryRoute(ValueChanged<String> changeUrl)
      : super(builder: (_) => BrowserHistoryScreen(changeUrl: changeUrl));
}

class BrowserHistoryScreen extends StatefulWidget {
  const BrowserHistoryScreen({
    required this.changeUrl,
    super.key,
  });

  final ValueChanged<String> changeUrl;

  @override
  State<BrowserHistoryScreen> createState() => _BrowserHistoryScreenState();
}

class _BrowserHistoryScreenState extends State<BrowserHistoryScreen> {
  final timeFormat = DateFormat('HH:mm');
  final dateFormat = DateFormat('EEEE, c MMMM y');
  final searchController = TextEditingController();
  final searchFocus = FocusNode();

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final historyRepo = context.read<SearchHistoryRepository>();

    return Scaffold(
      backgroundColor: ColorsRes.white,
      body: GestureDetector(
        onTap: () => searchFocus.unfocus(),
        child: StreamProvider<AsyncValue<List<SearchHistoryDto>>>(
          create: (_) => historyRepo.searchHistoryStream.map((event) => AsyncValue.ready(event)),
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
                .toList();
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 70, bottom: 16, right: 16, left: 16),
                    child: Text(
                      localization.history,
                      style: StylesRes.header2Faktum.copyWith(color: ColorsRes.black),
                    ),
                  ),
                ),
                if (searchHistory.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16).add(
                        const EdgeInsets.only(bottom: 16),
                      ),
                      child: _searchField(context),
                    ),
                  ),
                if (searchHistory.isEmpty)
                  _emptyHistory(localization.history_will_appear_here)
                else
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: searchController,
                    builder: (context, value, __) {
                      final history = value.text.isEmpty
                          ? searchHistory
                          : searchHistory.where((s) => s.url.contains(value.text)).toList();
                      return SliverList(
                        delegate: SliverChildListDelegate(
                          history
                              .mapIndex(
                                (e, index) => tile(
                                  context: context,
                                  entry: e,
                                  prevTileDate: index == 0 ? null : history[index - 1].openTime,
                                ),
                              )
                              .toList(),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _historyFooter(
        historyRepo,
        localization.clear_all_data,
        localization.done,
      ),
    );
  }

  Widget _searchField(BuildContext context) {
    final suffixIcon = TextFieldClearButton(
      focus: searchFocus,
      controller: searchController,
      iconColor: ColorsRes.bluePrimary400,
    );

    return BrowserSearchField(
      controller: searchController,
      focus: searchFocus,
      hintText: context.localization.search,
      suffixIcon: suffixIcon,
    );
  }

  Widget _historyFooter(SearchHistoryRepository repo, String clearData, String done) {
    return SafeArea(
      child: Material(
        color: ColorsRes.neutral950,
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: TextPrimaryButton(
                  text: clearData,
                  style: StylesRes.buttonText.copyWith(color: ColorsRes.red400Primary),
                  onPressed: () => repo.clear(),
                ),
              ),
              Expanded(
                child: TextPrimaryButton(
                  text: done,
                  style: StylesRes.buttonText.copyWith(color: ColorsRes.bluePrimary400),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyHistory(String text) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.images.history.svg(width: 66, height: 66),
            const SizedBox(height: 18),
            Text(
              text,
              style: StylesRes.regular16.copyWith(color: ColorsRes.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget tile({
    required BuildContext context,
    required SearchHistoryDto entry,
    required DateTime? prevTileDate,
  }) {
    final isUrl = isURL(entry.url);
    return FutureBuilder<SiteMetaData>(
      future: context.read<SitesMetaDataRepository>().getSiteMetaData(entry.url),
      builder: (context, snap) {
        final meta = snap.data;
        final image = meta?.image;

        final tile = EWListTile(
          onPressed: () {
            if (isUrl) {
              widget.changeUrl(entry.url);
            } else {
              widget.changeUrl(getDuckDuckGoSearchLink(entry.url));
            }
            Navigator.of(context).pop();
          },
          leading: image == null
              ? Assets.images.browser.iconGlobe.svg(width: 24, height: 24)
              : CircleAvatar(
                  maxRadius: 13,
                  child: image.endsWith('svg')
                      ? SvgPicture.network(image, width: 24, height: 24)
                      : Image.network(
                          image,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                ),
          titleWidget: Text(
            meta?.title != null ? meta!.title!.overflow : entry.url.overflow,
            style: StylesRes.basicText.copyWith(color: ColorsRes.black),
            overflow: TextOverflow.ellipsis,
          ),
          subtitleWidget: meta?.title == null
              ? null
              : Text(
                  entry.url.overflow,
                  style: StylesRes.subtitleStyle.copyWith(
                    color: ColorsRes.black.withOpacity(0.32),
                  ),
                ),
          trailing: Text(timeFormat.format(entry.openTime)),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prevTileDate == null || !isSameDayDates(entry.openTime, prevTileDate)) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  dateFormat.format(entry.openTime),
                  style: StylesRes.header3Faktum.copyWith(color: ColorsRes.black),
                ),
              ),
              const SizedBox(height: 20),
            ] else
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: DefaultDivider(),
              ),
            tile,
          ],
        );
      },
    );
  }

  bool isSameDayDates(DateTime date1, DateTime date2) =>
      date1.day == date2.day && date1.month == date2.month && date1.year == date2.year;
}
