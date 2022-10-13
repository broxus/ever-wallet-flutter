import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tab_item.dart';
import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tabs_cubit/browser_tabs_cubit.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';

class BrowserTabsViewerScreen extends StatefulWidget {
  final BrowserTabsCubit tabsCubit;

  const BrowserTabsViewerScreen({
    required this.tabsCubit,
    super.key,
  });

  @override
  State<BrowserTabsViewerScreen> createState() => _BrowserTabsViewerScreenState();
}

class _BrowserTabsViewerScreenState extends State<BrowserTabsViewerScreen> {
  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final size = MediaQuery.of(context).size;
    final itemWidth = (size.width - 44) / 2;
    final itemHeight = itemWidth / childAspectRation;

    return Scaffold(
      backgroundColor: ColorsRes.neutral900,
      body: GridView.builder(
        padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: itemWidth,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRation,
        ),
        itemCount: widget.tabsCubit.tabsCount,
        itemBuilder: (_, index) {
          final tabs = widget.tabsCubit.tabs;
          final tab = tabs[index];

          return BrowserTabItem(
            key: widget.tabsCubit.tabsNotifiers[index].tabKey,
            onOpen: () => widget.tabsCubit.openTab(index),
            onClose: () => widget.tabsCubit.closeTab(index),
            tab: tab,
            itemHeight: itemHeight,
            itemWidth: itemWidth,
            isCurrentActive: index == widget.tabsCubit.activeTabIndex,
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: ColorsRes.white,
        child: Row(
          children: [
            Expanded(
              child: TextPrimaryButton(
                text: localization.close_all,
                style: StylesRes.buttonText.copyWith(color: ColorsRes.bluePrimary400),
                onPressed: () => widget.tabsCubit.closeAllTabs(),
              ),
            ),
            Expanded(
              child: TextPrimaryButton(
                icon: const Icon(Icons.add, size: 24, color: ColorsRes.bluePrimary400),
                onPressed: () => widget.tabsCubit.openNewTab(),
              ),
            ),
            Expanded(
              child: TextPrimaryButton(
                text: localization.done,
                style: StylesRes.buttonText.copyWith(color: ColorsRes.bluePrimary400),
                onPressed: () => widget.tabsCubit.hideTabs(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
