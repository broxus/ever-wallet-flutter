import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../logger.dart';
import '../../../common/theme.dart';
import '../browser_page_logic.dart';
import '../extensions.dart';
import '../requests/code_to_tvc_handler.dart';
import '../requests/decode_event_handler.dart';
import '../requests/decode_input_handler.dart';
import '../requests/decode_output_handler.dart';
import '../requests/decode_transaction_events_handler.dart';
import '../requests/decode_transaction_handler.dart';
import '../requests/disconnect_handler.dart';
import '../requests/encode_internal_input_handler.dart';
import '../requests/estimate_fees_handler.dart';
import '../requests/extract_public_key_handler.dart';
import '../requests/get_expected_address_handler.dart';
import '../requests/get_full_contract_state_handler.dart';
import '../requests/get_provider_state_handler.dart';
import '../requests/get_transactions_handler.dart';
import '../requests/pack_into_cell_handler.dart';
import '../requests/request_permissions_handler.dart';
import '../requests/run_local_handler.dart';
import '../requests/send_external_message_handler.dart';
import '../requests/send_message_handler.dart';
import '../requests/split_tvc_handler.dart';
import '../requests/subscribe_handler.dart';
import '../requests/unpack_from_cell_handler.dart';
import '../requests/unsubscribe_all_handler.dart';
import '../requests/unsubscribe_handler.dart';
import '../utils.dart';

class BrowserWebView extends StatefulWidget {
  final Completer<InAppWebViewController> controller;
  final TextEditingController urlController;

  const BrowserWebView({
    Key? key,
    required this.controller,
    required this.urlController,
  }) : super(key: key);

  @override
  State<BrowserWebView> createState() => _BrowserWebViewState();
}

class _BrowserWebViewState extends State<BrowserWebView> {
  late final pullToRefreshController = PullToRefreshController(
    onRefresh: () => widget.controller.future.then((v) => v.refresh()),
  );

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) => ref.watch(mainScriptProvider).maybeWhen(
              data: (data) => DecoratedBox(
                decoration: const BoxDecoration(
                  color: CrystalColor.background,
                ),
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      useShouldOverrideUrlLoading: true,
                      mediaPlaybackRequiresUserGesture: false,
                      transparentBackground: true,
                    ),
                    android: AndroidInAppWebViewOptions(
                      disableDefaultErrorPage: true,
                      useHybridComposition: true,
                    ),
                    ios: IOSInAppWebViewOptions(
                      allowsInlineMediaPlayback: true,
                    ),
                  ),
                  initialUserScripts: UnmodifiableListView<UserScript>([
                    UserScript(
                      source: data,
                      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                    ),
                  ]),
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: onWebViewCreated,
                  onLoadStart: onLoadStart,
                  onLoadStop: (controller, url) => onLoadStop(ref.read, controller, url),
                  onLoadError: onLoadError,
                  onLoadHttpError: onLoadError,
                  onProgressChanged: (controller, progress) => onProgressChanged(ref.read, controller, progress),
                  onUpdateVisitedHistory: onUpdateVisitedHistory,
                  androidOnPermissionRequest: androidOnPermissionRequest,
                  shouldOverrideUrlLoading: shouldOverrideUrlLoading,
                  onConsoleMessage: onConsoleMessage,
                ),
              ),
              orElse: () => Center(
                child: PlatformCircularProgressIndicator(),
              ),
            ),
      );

  void onWebViewCreated(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'requestPermissions',
      callback: (args) => requestPermissionsHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'disconnect',
      callback: (args) => disconnectHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'subscribe',
      callback: (args) => subscribeHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'unsubscribe',
      callback: (args) => unsubscribeHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'unsubscribeAll',
      callback: (args) => unsubscribeAllHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getProviderState',
      callback: (args) => getProviderStateHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getFullContractState',
      callback: (args) => getFullContractStateHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getTransactions',
      callback: (args) => getTransactionsHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'runLocal',
      callback: (args) => runLocalHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getExpectedAddress',
      callback: (args) => getExpectedAddressHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'packIntoCell',
      callback: (args) => packIntoCellHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'unpackFromCell',
      callback: (args) => unpackFromCellHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'extractPublicKey',
      callback: (args) => extractPublicKeyHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'codeToTvc',
      callback: (args) => codeToTvcHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'splitTvc',
      callback: (args) => splitTvcHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'encodeInternalInput',
      callback: (args) => encodeInternalInputHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeInput',
      callback: (args) => decodeInputHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeEvent',
      callback: (args) => decodeEventHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeOutput',
      callback: (args) => decodeOutputHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeTransaction',
      callback: (args) => decodeTransactionHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeTransactionEvents',
      callback: (args) => decodeTransactionEventsHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'estimateFees',
      callback: (args) => estimateFeesHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'sendMessage',
      callback: (args) => sendMessageHandler(controller: controller, args: args),
    );

    controller.addJavaScriptHandler(
      handlerName: 'sendExternalMessage',
      callback: (args) => sendExternalMessageHandler(controller: controller, args: args),
    );

    widget.controller.complete(controller);
  }

  void onLoadStart(
    InAppWebViewController controller,
    Uri? url,
  ) =>
      updateUrlControllerValue(url);

  Future<void> onLoadStop(
    Reader read,
    InAppWebViewController controller,
    Uri? url,
  ) async {
    pullToRefreshController.endRefreshing();

    read(urlProvider.notifier).state = url;

    read(backButtonEnabledProvider.notifier).state = await controller.canGoBack();
    read(forwardButtonEnabledProvider.notifier).state = await controller.canGoForward();

    updateUrlControllerValue(url);
  }

  Future<void> onLoadError(
    InAppWebViewController controller,
    Uri? url,
    int code,
    String message,
  ) async {
    if (Platform.isIOS && code == -999) return;

    final errorUrl = url ?? Uri.parse('about:blank');

    controller.loadData(
      data: getErrorPage(url: errorUrl, message: message),
      baseUrl: errorUrl,
      androidHistoryUrl: errorUrl,
    );
  }

  void onProgressChanged(
    Reader read,
    InAppWebViewController controller,
    int progress,
  ) {
    if (progress == 100) pullToRefreshController.endRefreshing();
    read(progressProvider.notifier).state = progress;
  }

  void onUpdateVisitedHistory(
    InAppWebViewController controller,
    Uri? url,
    // ignore: avoid_positional_boolean_parameters
    bool? androidIsReload,
  ) =>
      updateUrlControllerValue(url);

  Future<PermissionRequestResponse?> androidOnPermissionRequest(
    InAppWebViewController controller,
    String origin,
    List<String> resources,
  ) async =>
      PermissionRequestResponse(
        resources: resources,
        action: PermissionRequestResponseAction.GRANT,
      );

  Future<NavigationActionPolicy?> shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final uri = navigationAction.request.url!;

    if (!['http', 'https', 'file', 'chrome', 'data', 'javascript', 'about'].contains(uri.scheme)) {
      final url = uri.toString();

      if (await canLaunch(url)) {
        await launch(url);

        return NavigationActionPolicy.CANCEL;
      }
    }

    return NavigationActionPolicy.ALLOW;
  }

  void onConsoleMessage(InAppWebViewController controller, ConsoleMessage message) {
    if (message.message == 'JavaScript execution returned a result of an unsupported type') return;

    logger.d(message.message, message.message);
  }

  void updateUrlControllerValue(Uri? url) {
    var text = url.toString();

    if (url == Uri.parse('about:blank')) text = '';

    widget.urlController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
