import 'package:ever_wallet/application/common/general/button/primary_icon_button.dart';
import 'package:ever_wallet/application/common/general/button/text_button.dart';
import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tabs_cubit/browser_tabs_cubit.dart';
import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_home.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class BrowserTabsScreen extends StatefulWidget {
  final BrowserTabsCubit tabsCubit;

  const BrowserTabsScreen({
    required this.tabsCubit,
    Key? key,
  }) : super(key: key);

  @override
  State<BrowserTabsScreen> createState() => _BrowserTabsScreenState();
}

class _BrowserTabsScreenState extends State<BrowserTabsScreen> {
  @override
  Widget build(BuildContext context) {
    final localization = context.localization;

    return Scaffold(
      backgroundColor: ColorsRes.neutral900,
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 160 / 190,
        ),
        itemCount: widget.tabsCubit.tabsCount,
        itemBuilder: (_, index) {
          final tab = widget.tabsCubit.tabs[index];
          return Material(
            color: Colors.transparent,
            elevation: 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: tab.url == aboutBlankPage || tab.url.isEmpty
                      ? IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: index == widget.tabsCubit.currentTabIndex
                                    ? ColorsRes.bluePrimary400
                                    : Colors.transparent,
                              ),
                            ),
                            child: const BrowserHome(urlCubit: null),
                          ),
                        )
                      : Html(data: tab.url),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: PrimaryIconButton(
                    backgroundColor: ColorsRes.blue950,
                    icon:
                        const Icon(Icons.close_rounded, size: 24, color: ColorsRes.bluePrimary400),
                    onPressed: () => widget.tabsCubit.closeTab(index),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: ColorsRes.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextPrimaryButton(
              text: localization.close_all,
              style: StylesRes.buttonText.copyWith(color: ColorsRes.bluePrimary400),
              onPressed: () => widget.tabsCubit.closeAllTabs(),
            ),
            TextPrimaryButton(
              icon: const Icon(Icons.add, size: 24, color: ColorsRes.bluePrimary400),
              onPressed: () => widget.tabsCubit.openNewTab(),
            ),
            TextPrimaryButton(
              text: localization.done,
              style: StylesRes.buttonText.copyWith(color: ColorsRes.bluePrimary400),
              onPressed: () => widget.tabsCubit.hideTabs(),
            ),
          ],
        ),
      ),
    );
  }
}
