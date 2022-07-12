import 'dart:async';

import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/unfocusing_gesture_detector.dart';
import 'package:ever_wallet/application/main/browser/back_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/forward_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/progress_cubit.dart';
import 'package:ever_wallet/application/main/browser/url_cubit.dart';
import 'package:ever_wallet/application/main/browser/widgets/approvals_listener.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_app_bar.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_history.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_home.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_web_view.dart';
import 'package:ever_wallet/application/main/browser/widgets/events_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    urlFocusNode.addListener(urlFocusNodeListener);
  }

  @override
  void dispose() {
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
                  child: AnnotatedRegion<SystemUiOverlayStyle>(
                    value: SystemUiOverlayStyle.dark,
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      backgroundColor: CrystalColor.iosBackground,
                      body: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            appBar(),
                            Expanded(
                              child: body(),
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
        ),
      );

  Widget appBar() => BrowserAppBar(
        controller: controller,
        urlController: urlController,
        urlFocusNode: urlFocusNode,
      );

  Widget body() => AnimatedBuilder(
        animation: urlFocusNode,
        builder: (context, child) => BlocBuilder<UrlCubit, Uri?>(
          builder: (context, state) {
            final url = state;

            var index = 0;

            if (url == Uri.parse('about:blank')) index = 1;

            if (urlFocusNode.hasFocus) index = 2;

            return IndexedStack(
              index: index,
              sizing: StackFit.expand,
              children: [
                BrowserWebView(
                  controller: controller,
                  urlController: urlController,
                ),
                BrowserHome(
                  controller: controller,
                ),
                UnfocusingGestureDetector(
                  child: BrowserHistory(
                    controller: controller,
                    urlFocusNode: urlFocusNode,
                  ),
                ),
              ],
            );
          },
        ),
      );
}
