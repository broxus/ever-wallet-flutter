import 'dart:collection';

import 'package:crystal/domain/blocs/misc/approvals_bloc.dart';
import 'package:crystal/domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import 'package:crystal/injection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'dialog.dart';

class WebviewPage extends StatefulWidget {
  final String address;
  final String url;

  const WebviewPage({
    Key? key,
    required this.address,
    required this.url,
  }) : super(key: key);

  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  final approvalsBloc = getIt.get<ApprovalsBloc>();
  late final TonWalletInfoBloc tonWalletInfoBloc;

  @override
  void initState() {
    super.initState();
    tonWalletInfoBloc = getIt.get<TonWalletInfoBloc>(param1: widget.address);
  }

  @override
  void dispose() {
    approvalsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<ApprovalsBloc, ApprovalsState>(
        bloc: approvalsBloc,
        listener: (context, state) async {
          await showApprovalDialog(context);
        },
        child: Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            bottom: false,
            child: buildBody(),
          ),
        ),
      );

  Widget buildBody() => FutureBuilder<String>(
        future: loadMainScript(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
              initialUserScripts: UnmodifiableListView<UserScript>([
                UserScript(
                  source: snapshot.data!,
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                ),
              ]),
              initialOptions: InAppWebViewGroupOptions(
                android: AndroidInAppWebViewOptions(
                  useHybridComposition: true,
                ),
              ),
              onWebViewCreated: (controller) {
                controller.addJavaScriptHandler(
                  handlerName: 'requestPermissions',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'disconnect',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'subscribe',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'unsubscribe',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'unsubscribeAll',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'getProviderState',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'getFullContractState',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'getTransactions',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'runLocal',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'getExpectedAddress',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'packIntoCell',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'unpackFromCell',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'extractPublicKey',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'codeToTvc',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'splitTvc',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'encodeInternalInput',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'decodeInput',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'decodeEvent',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'decodeOutput',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'decodeTransaction',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'decodeTransactionEvents',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'estimateFees',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'sendMessage',
                  callback: (arguments) {},
                );

                controller.addJavaScriptHandler(
                  handlerName: 'sendExternalMessage',
                  callback: (arguments) {},
                );
              },
              onLoadStop: (controller, url) {
                controller.evaluateJavascript(source: 'console.log("loaded")');
              },
              onConsoleMessage: (controller, consoleMessage) {
                debugPrint(consoleMessage.message);
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      );
}
