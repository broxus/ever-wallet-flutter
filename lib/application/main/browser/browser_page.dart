import 'dart:async';

import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/button/primary_icon_button.dart';
import 'package:ever_wallet/application/main/browser/back_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tabs_cubit/browser_tabs_cubit.dart';
import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tabs_screen.dart';
import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/forward_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/progress_cubit.dart';
import 'package:ever_wallet/application/main/browser/url_cubit.dart';
import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:ever_wallet/application/main/browser/widgets/approvals_listener.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_app_bar/browser_app_bar.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_app_bar/browser_app_bar_scroll_listener.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_home.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_web_view.dart';
import 'package:ever_wallet/application/main/browser/widgets/events_listener.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/data/repositories/sites_meta_data_repository.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({Key? key}) : super(key: key);

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  final controller = Completer<InAppWebViewController>();
  final urlController = TextEditingController();
  final urlFocusNode = FocusNode();
  final browserListener = BrowserAppBarScrollListener();
  late final BrowserTabsCubit browserTabsCubit;
  final urlCubit = UrlCubit();

  late bool showedWhyNeedBrowser;

  @override
  void initState() {
    super.initState();
    urlFocusNode.addListener(urlFocusNodeListener);
    final source = context.read<HiveSource>();
    showedWhyNeedBrowser = source.getWhyNeedBrowser;
    browserTabsCubit = BrowserTabsCubit(
      source,
      urlCubit.setUrl,
      context.read<SitesMetaDataRepository>(),
    );
    if (!showedWhyNeedBrowser) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showWhyNeedBrowserDialog());
    }
  }

  @override
  void dispose() {
    browserListener.dispose();
    urlController.dispose();
    urlCubit.close();
    browserTabsCubit.close();
    urlFocusNode.removeListener(urlFocusNodeListener);
    super.dispose();
  }

  void urlFocusNodeListener() => urlController.value = urlController.value.copyWith(
        selection: TextSelection(
          baseOffset: 0,
          extentOffset: urlController.text.length,
        ),
      );

  @override
  Widget build(BuildContext context) => BlocProvider<BackButtonEnabledCubit>(
        create: (context) => BackButtonEnabledCubit(),
        child: BlocProvider<ForwardButtonEnabledCubit>(
          create: (context) => ForwardButtonEnabledCubit(),
          child: BlocProvider<ProgressCubit>(
            create: (context) => ProgressCubit(),
            child: BlocProvider<UrlCubit>(
              create: (context) => urlCubit,
              child: EventsListener(
                controller: controller,
                child: ApprovalsListener(
                  child: BlocConsumer<UrlCubit, String?>(
                    listener: (_, url) async {
                      /// Update all url dependent objects
                      if (url != null) {
                        final webController = await controller.future;
                        final webUrl = (await webController.getUrl()).toString();

                        if (urlController.text != url) urlController.text = url;
                        browserTabsCubit.updateCurrentTab(url);
                        if (webUrl == url) return;
                        if (url == aboutBlankPage) {
                          controller.future.then((c) => c.goHome());
                        } else {
                          controller.future.then((c) => c.tryLoadUrl(url));
                        }
                      }
                    },
                    builder: (context, url) {
                      return BlocBuilder<BrowserTabsCubit, BrowserTabsCubitState>(
                        bloc: browserTabsCubit,
                        builder: (_, tabsState) {
                          final index = tabsState.when(
                            showTabs: (_) => 0,
                            hideTabs: (_) => 1,
                          );

                          // stack is used here to avoid deleting webview from the tree
                          return IndexedStack(
                            index: index,
                            children: [
                              BrowserTabsScreen(tabsCubit: browserTabsCubit),
                              Scaffold(
                                resizeToAvoidBottomInset: false,
                                backgroundColor: ColorsRes.white,
                                body: SafeArea(
                                  child: Stack(
                                    children: [
                                      Positioned.fill(child: body(url)),
                                      ValueListenableBuilder<double>(
                                        valueListenable: browserListener,
                                        builder: (_, show, __) {
                                          final size = MediaQuery.of(context).size;

                                          return Positioned(
                                            top: show,
                                            width: size.width,
                                            child: appBar(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget appBar() => BrowserAppBar(
        key: browserListener.browserFlexibleKey,
        controller: controller,
        urlController: urlController,
        urlFocusNode: urlFocusNode,
        tabsCubit: browserTabsCubit,
        urlCubit: urlCubit,
      );

  Widget body(String? url) {
    var index = 0;

    if (url == aboutBlankPage) index = 1;

    return Column(
      children: [
        // This displays separately from Expanded to reduce webview re-render
        ValueListenableBuilder<double>(
          valueListenable: browserListener,
          builder: (_, show, __) => SizedBox(
            height: BrowserAppBarScrollListener.appBarHeight + show,
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: index,
            sizing: StackFit.expand,
            children: [
              BrowserWebView(
                controller: controller,
                urlController: urlController,
                browserListener: browserListener,
              ),
              BrowserHome(urlCubit: urlCubit),
            ],
          ),
        )
      ],
    );
  }

  void _showWhyNeedBrowserDialog() {
    showDialog<void>(
      context: context,
      barrierColor: ColorsRes.black.withOpacity(0.3),
      builder: (context) {
        final localization = context.localization;
        return Dialog(
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
