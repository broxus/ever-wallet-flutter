import 'dart:async';

import 'package:ever_wallet/application/main/browser/back_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/forward_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/progress_cubit.dart';
import 'package:ever_wallet/application/main/browser/url_cubit.dart';
import 'package:ever_wallet/application/main/browser/widgets/approvals_listener.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_app_bar/browser_app_bar.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_app_bar/browser_app_bar_scroll_listener.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_home.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_web_view.dart';
import 'package:ever_wallet/application/main/browser/widgets/events_listener.dart';
import 'package:ever_wallet/application/util/colors.dart';
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

  @override
  void initState() {
    super.initState();
    urlFocusNode.addListener(urlFocusNodeListener);
  }

  @override
  void dispose() {
    browserListener.dispose();
    urlController.dispose();
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
              create: (context) => UrlCubit(),
              child: EventsListener(
                controller: controller,
                child: ApprovalsListener(
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    backgroundColor: ColorsRes.white,
                    body: SafeArea(
                      child: Stack(
                        children: [
                          Positioned.fill(child: body()),
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
      );

  Widget body() => BlocBuilder<UrlCubit, Uri?>(
        builder: (context, state) {
          final url = state;

          var index = 0;

          if (url == Uri.parse('about:blank')) index = 1;

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
                    BrowserHome(controller: controller),
                  ],
                ),
              )
            ],
          );
        },
      );
}
