import 'package:ever_wallet/application/common/general/button/primary_icon_button.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tabs_cubit/browser_tabs_cubit.dart';
import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_home.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';

class BrowserTabsViewerScreen extends StatefulWidget {
  final BrowserTabsCubit tabsCubit;

  const BrowserTabsViewerScreen({
    required this.tabsCubit,
    Key? key,
  }) : super(key: key);

  @override
  State<BrowserTabsViewerScreen> createState() => _BrowserTabsViewerScreenState();
}

class _BrowserTabsViewerScreenState extends State<BrowserTabsViewerScreen> {
  static const childAspectRation = 160 / 190;

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

          return GestureDetector(
            onTap: () => widget.tabsCubit.openTab(index),
            child: Material(
              color: Colors.white,
              elevation: 5,
              child: SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: SizedBox(
                        width: itemWidth,
                        height: itemHeight,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.5,
                                color: index == widget.tabsCubit.activeTabIndex
                                    ? ColorsRes.bluePrimary400
                                    : Colors.transparent,
                              ),
                            ),
                            child: FittedBox(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 400,
                                  maxWidth: 400 * childAspectRation,
                                ),
                                child: tab.url == aboutBlankPage || tab.url.isEmpty
                                    ? BrowserHome(changeUrl: (_) {})
                                    : Container(
                                        decoration: const BoxDecoration(color: Colors.white),
                                        width: double.infinity,
                                        child: tab.screenshot != null
                                            ? Image.memory(tab.screenshot!, fit: BoxFit.cover)
                                            : null,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: PrimaryIconButton(
                        backgroundColor: ColorsRes.blue950,
                        outerPadding: EdgeInsets.zero,
                        innerPadding: const EdgeInsets.all(4),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: ColorsRes.bluePrimary400,
                        ),
                        onPressed: () => widget.tabsCubit.closeTab(index),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
