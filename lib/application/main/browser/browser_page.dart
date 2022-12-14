import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/button/primary_icon_button.dart';
import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tabs_cubit/browser_tabs_cubit.dart';
import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tabs_cubit/browser_tabs_notifiers.dart';
import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tabs_screen.dart';
import 'package:ever_wallet/application/main/browser/widgets/approvals_listener.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_tab_widget.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/extensions/iterable_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/data/repositories/sites_meta_data_repository.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({super.key});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  late final BrowserTabsCubit browserTabsCubit;

  late bool showedWhyNeedBrowser;

  @override
  void initState() {
    super.initState();
    final source = context.read<HiveSource>();
    showedWhyNeedBrowser = source.getWhyNeedBrowser;
    browserTabsCubit = BrowserTabsCubit(
      source,
      context.read<SitesMetaDataRepository>(),
    );
    if (!showedWhyNeedBrowser) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showWhyNeedBrowserDialog());
    }
  }

  @override
  void dispose() {
    browserTabsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: ApprovalsListener(
          child: BlocBuilder<BrowserTabsCubit, BrowserTabsCubitState>(
            bloc: browserTabsCubit,
            builder: (_, tabsState) {
              final index = tabsState.when(
                showTabs: (_, __, ___) => 0,
                hideTabs: (_, __, ___) => 1,
              );

              return IndexedStack(
                index: index,
                children: [
                  BrowserTabsViewerScreen(tabsCubit: browserTabsCubit),
                  _buildTabs(tabsState.tabs),
                ],
              );
            },
          ),
        ),
      );

  Widget _buildTabs(BrowserTabsList tabs) {
    return IndexedStack(
      index: tabs.lastActiveIndex,
      children: tabs.tabs
          .mapIndex(
            (tab, index) => BrowserTabWidget(
              key: tab.webViewTabKey,
              tab: tab,
              tabsCubit: browserTabsCubit,
            ),
          )
          .toList(),
    );
  }

  void _showWhyNeedBrowserDialog() {
    showDialog<void>(
      context: context,
      barrierColor: ColorsRes.black.withOpacity(0.3),
      builder: (context) {
        final localization = context.localization;
        return Dialog(
          alignment: Alignment.bottomCenter,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320, maxHeight: 400),
            child: Stack(
              children: [
                Positioned.fill(
                  top: 16,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Assets.images.browser.whyNeedBrowser.svg(fit: BoxFit.fitWidth),
                        const SizedBox(height: 20),
                        Text(
                          localization.why_need_browser,
                          style: StylesRes.bold20.copyWith(color: ColorsRes.black),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          localization.whe_need_browser_description,
                          style: StylesRes.basicText.copyWith(color: ColorsRes.black),
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          text: localization.got_it,
                          backgroundColor: ColorsRes.bluePrimary400,
                          style: StylesRes.buttonText.copyWith(color: ColorsRes.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: PrimaryIconButton(
                    icon: Assets.images.iconCross.svg(color: ColorsRes.bluePrimary400),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) => context.read<HiveSource>().saveWhyNeedBrowser());
  }
}
