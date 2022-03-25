import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/theme.dart';
import '../../common/widgets/unfocusing_gesture_detector.dart';
import 'browser_page_logic.dart';
import 'custom_in_app_web_view_controller.dart';
import 'widgets/approvals_listener.dart';
import 'widgets/browser_app_bar.dart';
import 'widgets/browser_history.dart';
import 'widgets/browser_home.dart';
import 'widgets/browser_web_view.dart';
import 'widgets/events_listener.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({Key? key}) : super(key: key);

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  final controller = Completer<CustomInAppWebViewController>();
  final urlController = TextEditingController();
  final urlFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    urlFocusNode.addListener(urlFocusNodeListener);
  }

  @override
  void dispose() {
    controller.future.then((v) => v.dispose());
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
  Widget build(BuildContext context) => EventsListener(
        controller: controller,
        child: ApprovalsListener(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: CrystalColor.iosBackground,
                body: SafeArea(
                  bottom: false,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeBottom: true,
                    removeTop: true,
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
      );

  Widget appBar() => BrowserAppBar(
        controller: controller,
        urlController: urlController,
        urlFocusNode: urlFocusNode,
      );

  Widget body() => AnimatedBuilder(
        animation: urlFocusNode,
        builder: (context, child) => Consumer(
          builder: (context, ref, child) {
            final url = ref.watch(urlProvider);

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
