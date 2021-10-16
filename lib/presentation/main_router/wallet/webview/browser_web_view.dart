import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../logger.dart';
import 'provider_requests_handlers.dart';

class BrowserWebView extends StatefulWidget {
  final Future<void> Function(
    InAppWebViewController controller,
    Uri? url,
  ) onLoadStop;
  final Future<void> Function(
    InAppWebViewController controller,
    int progress,
  ) onProgressChanged;

  const BrowserWebView({
    Key? key,
    required this.onLoadStop,
    required this.onProgressChanged,
  }) : super(key: key);

  @override
  _BrowserWebViewState createState() => _BrowserWebViewState();
}

class _BrowserWebViewState extends State<BrowserWebView> {
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
              initialOptions: InAppWebViewGroupOptions(),
              onWebViewCreated: onProviderWebViewCreated,
              onLoadStop: widget.onLoadStop,
              onConsoleMessage: onConsoleMessage,
              onProgressChanged: widget.onProgressChanged,
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
