import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../../logger.dart';
import 'controller_extensions.dart';
import 'provider_requests_handlers.dart';

class BrowserWebView extends StatefulWidget {
  final PullToRefreshController pullToRefreshController;
  final Future<void> Function(
    InAppWebViewController controller,
  ) onWebViewCreated;
  final Future<void> Function(
    InAppWebViewController controller,
    Uri? url,
  ) onLoadStart;
  final Future<void> Function(
    InAppWebViewController controller,
    Uri? url,
  ) onLoadStop;
  final Future<void> Function(
    InAppWebViewController controller,
    int progress,
  ) onProgressChanged;
  final void Function(
    InAppWebViewController controller,
    Uri? url,
    bool? androidIsReload,
  ) onUpdateVisitedHistory;

  const BrowserWebView({
    Key? key,
    required this.pullToRefreshController,
    required this.onWebViewCreated,
    required this.onLoadStart,
    required this.onLoadStop,
    required this.onProgressChanged,
    required this.onUpdateVisitedHistory,
  }) : super(key: key);

  @override
  _BrowserWebViewState createState() => _BrowserWebViewState();
}

class _BrowserWebViewState extends State<BrowserWebView> {
  final initialUrlRequest = URLRequest(url: Uri.parse('https://www.google.com/'));
  final initialOptions = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: loadMainScript(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return InAppWebView(
              initialUserScripts: UnmodifiableListView<UserScript>([
                UserScript(
                  source: snapshot.data!,
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                ),
              ]),
              initialUrlRequest: initialUrlRequest,
              initialOptions: initialOptions,
              pullToRefreshController: widget.pullToRefreshController,
              onWebViewCreated: onProviderWebViewCreated,
              onLoadStart: widget.onLoadStart,
              onLoadStop: onLoadStop,
              onLoadError: onLoadError,
              onLoadHttpError: onLoadHttpError,
              onProgressChanged: onProgressChanged,
              onUpdateVisitedHistory: widget.onUpdateVisitedHistory,
              androidOnPermissionRequest: androidOnPermissionRequest,
              shouldOverrideUrlLoading: shouldOverrideUrlLoading,
              onConsoleMessage: onConsoleMessage,
            );
          } else {
            return Center(
              child: PlatformCircularProgressIndicator(),
            );
          }
        },
      );

  void onProviderWebViewCreated(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'requestPermissions',
      callback: (List<dynamic> args) => requestPermissionsHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'disconnect',
      callback: (List<dynamic> args) => disconnectHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'subscribe',
      callback: (List<dynamic> args) => subscribeHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'unsubscribe',
      callback: (List<dynamic> args) => unsubscribeHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'unsubscribeAll',
      callback: (List<dynamic> args) => unsubscribeAllHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getProviderState',
      callback: (List<dynamic> args) => getProviderStateHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getFullContractState',
      callback: (List<dynamic> args) => getFullContractStateHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getTransactions',
      callback: (List<dynamic> args) => getTransactionsHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'runLocal',
      callback: (List<dynamic> args) => runLocalHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getExpectedAddress',
      callback: (List<dynamic> args) => getExpectedAddressHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'packIntoCell',
      callback: (List<dynamic> args) => packIntoCellHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'unpackFromCell',
      callback: (List<dynamic> args) => unpackFromCellHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'extractPublicKey',
      callback: (List<dynamic> args) => extractPublicKeyHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'codeToTvc',
      callback: (List<dynamic> args) => codeToTvcHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'splitTvc',
      callback: (List<dynamic> args) => splitTvcHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'encodeInternalInput',
      callback: (List<dynamic> args) => encodeInternalInputHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeInput',
      callback: (List<dynamic> args) => decodeInputHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeEvent',
      callback: (List<dynamic> args) => decodeEventHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeOutput',
      callback: (List<dynamic> args) => decodeOutputHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeTransaction',
      callback: (List<dynamic> args) => decodeTransactionHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeTransactionEvents',
      callback: (List<dynamic> args) => decodeTransactionEventsHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'estimateFees',
      callback: (List<dynamic> args) => estimateFeesHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'sendMessage',
      callback: (List<dynamic> args) => sendMessageHandler(
        controller: controller,
        args: args,
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'sendExternalMessage',
      callback: (List<dynamic> args) => sendExternalMessageHandler(
        controller: controller,
        args: args,
      ),
    );

    widget.onWebViewCreated(controller);
  }

  void onLoadStop(InAppWebViewController controller, Uri? url) {
    controller.onLoaded(url);
    widget.pullToRefreshController.endRefreshing();
    widget.onLoadStop(controller, url);
  }

  void onLoadHttpError(InAppWebViewController controller, Uri? url, int statusCode, String description) {
    controller.onError(url, statusCode, description);
    controller.openInitialPage();
    widget.pullToRefreshController.endRefreshing();
  }

  void onLoadError(InAppWebViewController controller, Uri? url, int code, String message) {
    controller.onError(url, code, message);
    controller.openInitialPage();
    widget.pullToRefreshController.endRefreshing();
  }

  void onProgressChanged(InAppWebViewController controller, int progress) {
    if (progress == 100) {
      widget.pullToRefreshController.endRefreshing();
    }

    widget.onProgressChanged(controller, progress);
  }

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

  void onConsoleMessage(
    InAppWebViewController controller,
    ConsoleMessage consoleMessage,
  ) {
    if (consoleMessage.message == 'JavaScript execution returned a result of an unsupported type') {
      return;
    }

    if (consoleMessage.messageLevel == ConsoleMessageLevel.DEBUG) {
      logger.d(consoleMessage.message);
    } else if (consoleMessage.messageLevel == ConsoleMessageLevel.ERROR) {
      logger.e(consoleMessage.message);
    } else if (consoleMessage.messageLevel == ConsoleMessageLevel.LOG) {
      logger.d(consoleMessage.message);
    } else if (consoleMessage.messageLevel == ConsoleMessageLevel.TIP) {
      logger.d(consoleMessage.message);
    } else if (consoleMessage.messageLevel == ConsoleMessageLevel.WARNING) {
      logger.w(consoleMessage.message);
    }
  }
}
