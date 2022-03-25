import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../logger.dart';
import '../browser_page_logic.dart';
import '../custom_in_app_web_view_controller.dart';
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

class BrowserWebView extends StatefulWidget {
  final Completer<CustomInAppWebViewController> controller;
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
              data: (data) => InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true,
                    mediaPlaybackRequiresUserGesture: false,
                    transparentBackground: true,
                  ),
                  android: AndroidInAppWebViewOptions(
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
                onLoadHttpError: onLoadHttpError,
                onProgressChanged: (controller, progress) => onProgressChanged(ref.read, controller, progress),
                onUpdateVisitedHistory: onUpdateVisitedHistory,
                androidOnPermissionRequest: androidOnPermissionRequest,
                shouldOverrideUrlLoading: shouldOverrideUrlLoading,
              ),
              orElse: () => Center(
                child: PlatformCircularProgressIndicator(),
              ),
            ),
      );

  void onWebViewCreated(InAppWebViewController controller) {
    final customController = CustomInAppWebViewController(controller);

    customController.addJavaScriptHandler(
      handlerName: 'requestPermissions',
      callback: (args) => requestPermissionsHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'disconnect',
      callback: (args) => disconnectHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'subscribe',
      callback: (args) => subscribeHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'unsubscribe',
      callback: (args) => unsubscribeHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'unsubscribeAll',
      callback: (args) => unsubscribeAllHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'getProviderState',
      callback: (args) => getProviderStateHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'getFullContractState',
      callback: (args) => getFullContractStateHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'getTransactions',
      callback: (args) => getTransactionsHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'runLocal',
      callback: (args) => runLocalHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'getExpectedAddress',
      callback: (args) => getExpectedAddressHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'packIntoCell',
      callback: (args) => packIntoCellHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'unpackFromCell',
      callback: (args) => unpackFromCellHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'extractPublicKey',
      callback: (args) => extractPublicKeyHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'codeToTvc',
      callback: (args) => codeToTvcHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'splitTvc',
      callback: (args) => splitTvcHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'encodeInternalInput',
      callback: (args) => encodeInternalInputHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'decodeInput',
      callback: (args) => decodeInputHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'decodeEvent',
      callback: (args) => decodeEventHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'decodeOutput',
      callback: (args) => decodeOutputHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'decodeTransaction',
      callback: (args) => decodeTransactionHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'decodeTransactionEvents',
      callback: (args) => decodeTransactionEventsHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'estimateFees',
      callback: (args) => estimateFeesHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'sendMessage',
      callback: (args) => sendMessageHandler(controller: customController, args: args),
    );

    customController.addJavaScriptHandler(
      handlerName: 'sendExternalMessage',
      callback: (args) => sendExternalMessageHandler(controller: customController, args: args),
    );

    widget.controller.complete(customController);
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
    widget.controller.future.then((v) => v.onLoaded(url));

    pullToRefreshController.endRefreshing();

    read(urlProvider.notifier).state = url;

    read(backButtonEnabledProvider.notifier).state = await widget.controller.future.then((v) => v.canGoBack()) ?? false;
    read(forwardButtonEnabledProvider.notifier).state =
        await widget.controller.future.then((v) => v.canGoForward()) ?? false;

    updateUrlControllerValue(url);
  }

  void onLoadError(
    InAppWebViewController controller,
    Uri? url,
    int code,
    String message,
  ) {
    logger.e(message);
    widget.controller.future.then((v) => v.onError(url, code, message));
    pullToRefreshController.endRefreshing();
  }

  void onLoadHttpError(
    InAppWebViewController controller,
    Uri? url,
    int statusCode,
    String description,
  ) {
    logger.e(description);
    widget.controller.future.then((v) => v.onError(url, statusCode, description));
    pullToRefreshController.endRefreshing();
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

  void updateUrlControllerValue(Uri? url) {
    var text = url.toString();

    if (url == Uri.parse('about:blank')) text = '';

    widget.urlController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
