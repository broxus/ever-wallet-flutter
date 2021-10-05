import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:crystal/domain/blocs/provider/approvals_bloc.dart';
import 'package:crystal/domain/blocs/provider/provider_events_bloc.dart';
import 'package:crystal/domain/blocs/provider/provider_requests_bloc.dart';
import 'package:crystal/domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import 'package:crystal/injection.dart';
import 'package:crystal/logger.dart';
import 'package:crystal/presentation/design/design.dart';
import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import 'approval_dialogs.dart';

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
  final providerRequestsBloc = getIt.get<ProviderRequestsBloc>();
  final providerEventsBloc = getIt.get<ProviderEventsBloc>();
  final inAppWebViewControllerCompleter = Completer<InAppWebViewController>();
  late final String origin;

  @override
  void initState() {
    super.initState();
    tonWalletInfoBloc = getIt.get<TonWalletInfoBloc>(param1: widget.address);
    origin = widget.url;
  }

  @override
  void dispose() {
    approvalsBloc.close();
    tonWalletInfoBloc.close();
    providerRequestsBloc.close();
    providerEventsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TonWalletInfoBloc, TonWalletInfoState>(
        bloc: tonWalletInfoBloc,
        builder: (context, tonWalletInfoState) => tonWalletInfoState.maybeWhen(
          ready: (address, contractState, walletType, details, publicKey) =>
              BlocListener<ApprovalsBloc, ApprovalsState>(
            bloc: approvalsBloc,
            listener: (context, state) async {
              state.maybeWhen(
                requested: (request) => request.when(
                  requestPermissions: (origin, permissions, completer) => onRequestPermissions(
                    origin: origin,
                    permissions: permissions,
                    completer: completer,
                    address: address,
                    publicKey: publicKey,
                    walletType: walletType,
                  ),
                  sendMessage: (origin, sender, recipient, amount, bounce, payload, knownPayload, completer) =>
                      onSendMessage(
                    origin: origin,
                    sender: sender,
                    recipient: recipient,
                    amount: amount,
                    bounce: bounce,
                    payload: payload,
                    knownPayload: knownPayload,
                    completer: completer,
                  ),
                  callContractMethod: (origin, selectedPublicKey, repackedRecipient, payload, completer) =>
                      onCallContractMethod(
                    origin: origin,
                    selectedPublicKey: selectedPublicKey,
                    repackedRecipient: repackedRecipient,
                    payload: payload,
                    completer: completer,
                  ),
                ),
                orElse: () => null,
              );
            },
            child: BlocListener<ProviderEventsBloc, ProviderEventsState>(
              bloc: providerEventsBloc,
              listener: (context, state) => state.maybeWhen(
                disconnected: disconnectedCaller,
                transactionsFound: transactionsFoundCaller,
                contractStateChanged: contractStateChangedCaller,
                networkChanged: networkChangedCaller,
                permissionsChanged: permissionsChangedCaller,
                loggedOut: loggedOutCaller,
                orElse: () => null,
              ),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ExpandTapWidget(
                            onTap: context.router.pop,
                            tapPadding: const EdgeInsets.all(16),
                            child: Material(
                              type: MaterialType.transparency,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16, top: 12),
                                child: SizedBox(
                                  height: 24,
                                  child: PlatformWidget(
                                    material: (context, _) => Assets.images.iconBackAndroid.image(
                                      color: CrystalColor.accent,
                                      width: 24,
                                    ),
                                    cupertino: (context, _) => Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.arrow_back_ios_sharp,
                                          color: CrystalColor.accent,
                                          size: 14,
                                        ),
                                        const CrystalDivider(width: 3),
                                        Text(
                                          LocaleKeys.actions_back.tr(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: CrystalColor.accent,
                                            letterSpacing: 0.75,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 26),
                          child: buildBody(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          orElse: () => Center(
            child: PlatformCircularProgressIndicator(),
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
                  callback: requestPermissionsHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'disconnect',
                  callback: disconnectHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'subscribe',
                  callback: subscribeHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'unsubscribe',
                  callback: unsubscribeHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'unsubscribeAll',
                  callback: unsubscribeAllHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'getProviderState',
                  callback: getProviderStateHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'getFullContractState',
                  callback: getFullContractStateHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'getTransactions',
                  callback: getTransactionsHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'runLocal',
                  callback: runLocalHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'getExpectedAddress',
                  callback: getExpectedAddressHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'packIntoCell',
                  callback: packIntoCellHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'unpackFromCell',
                  callback: unpackFromCellHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'extractPublicKey',
                  callback: extractPublicKeyHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'codeToTvc',
                  callback: codeToTvcHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'splitTvc',
                  callback: splitTvcHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'encodeInternalInput',
                  callback: encodeInternalInputHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'decodeInput',
                  callback: decodeInputHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'decodeEvent',
                  callback: decodeEventHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'decodeOutput',
                  callback: decodeOutputHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'decodeTransaction',
                  callback: decodeTransactionHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'decodeTransactionEvents',
                  callback: decodeTransactionEventsHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'estimateFees',
                  callback: estimateFeesHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'sendMessage',
                  callback: sendMessageHandler,
                );

                controller.addJavaScriptHandler(
                  handlerName: 'sendExternalMessage',
                  callback: sendExternalMessageHandler,
                );
              },
              onLoadStop: (controller, url) {
                inAppWebViewControllerCompleter.complete(controller);
              },
              onConsoleMessage: (controller, consoleMessage) {
                if (consoleMessage.messageLevel == ConsoleMessageLevel.DEBUG) {
                  logger.d(consoleMessage.message);
                } else if (consoleMessage.messageLevel == ConsoleMessageLevel.ERROR) {
                  logger.e(consoleMessage.message, consoleMessage.message);
                } else if (consoleMessage.messageLevel == ConsoleMessageLevel.LOG) {
                  logger.d(consoleMessage.message);
                } else if (consoleMessage.messageLevel == ConsoleMessageLevel.TIP) {
                  logger.d(consoleMessage.message);
                } else if (consoleMessage.messageLevel == ConsoleMessageLevel.WARNING) {
                  logger.w(consoleMessage.message);
                }
              },
            );
          } else {
            return Center(child: PlatformCircularProgressIndicator());
          }
        },
      );

  Future<void> onRequestPermissions({
    required String origin,
    required List<Permission> permissions,
    required Completer<Permissions> completer,
    required String address,
    required String publicKey,
    required WalletType walletType,
  }) async {
    final result = await showRequestPermissionsDialog(
      context,
      origin: origin,
      permissions: permissions,
      address: address,
      publicKey: publicKey,
    );

    if (result) {
      var grantedPermissions = const Permissions();

      for (final permission in permissions) {
        switch (permission) {
          case Permission.tonClient:
            grantedPermissions = grantedPermissions.copyWith(tonClient: true);
            break;
          case Permission.accountInteraction:
            final contractType = walletType.when(
              multisig: (multisigType) {
                switch (multisigType) {
                  case MultisigType.safeMultisigWallet:
                    return WalletContractType.safeMultisigWallet;
                  case MultisigType.safeMultisigWallet24h:
                    return WalletContractType.safeMultisigWallet24h;
                  case MultisigType.setcodeMultisigWallet:
                    return WalletContractType.setcodeMultisigWallet;
                  case MultisigType.bridgeMultisigWallet:
                    return WalletContractType.bridgeMultisigWallet;
                  case MultisigType.surfWallet:
                    return WalletContractType.surfWallet;
                }
              },
              walletV3: () => WalletContractType.walletV3,
            );

            grantedPermissions = grantedPermissions.copyWith(
              accountInteraction: AccountInteraction(
                address: address,
                publicKey: publicKey,
                contractType: contractType,
              ),
            );
            break;
        }
      }

      completer.complete(grantedPermissions);
    } else {
      completer.completeError(Exception('Not granted'));
    }
  }

  Future<void> onSendMessage({
    required String origin,
    required String sender,
    required String recipient,
    required String amount,
    required bool bounce,
    required FunctionCall? payload,
    required KnownPayload? knownPayload,
    required Completer<String> completer,
  }) async {
    final result = await showSendMessageDialog(
      context,
      origin: origin,
      sender: sender,
      recipient: recipient,
      amount: amount,
      bounce: bounce,
      payload: payload,
      knownPayload: knownPayload,
    );

    if (result != null) {
      completer.complete(result);
    } else {
      completer.completeError(Exception('No password'));
    }
  }

  Future<void> onCallContractMethod({
    required String origin,
    required String selectedPublicKey,
    required String repackedRecipient,
    required FunctionCall payload,
    required Completer<String> completer,
  }) async {
    final result = await showCallContractMethodDialog(
      context,
      origin: origin,
      selectedPublicKey: selectedPublicKey,
      repackedRecipient: repackedRecipient,
      payload: payload,
    );

    if (result != null) {
      completer.complete(result);
    } else {
      completer.completeError(Exception('No password'));
    }
  }

  Future<void> disconnectedCaller(Error event) async {
    try {
      final jsonOutput = jsonEncode(event.toJson());
      logger.d('EVENT disconnected $jsonOutput');

      final controller = await inAppWebViewControllerCompleter.future;
      final result = await controller.evaluateJavascript(source: "window.__dartNotifications.disconnected('$jsonOutput')");

      logger.d('EVENT disconnected $result');
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<void> transactionsFoundCaller(TransactionsFoundEvent event) async {
    try {
      final jsonOutput = jsonEncode(event.toJson());
      logger.d('EVENT transactionsFound $jsonOutput');

      final controller = await inAppWebViewControllerCompleter.future;
      final result = await controller.evaluateJavascript(source: "window.__dartNotifications.transactionsFound('$jsonOutput')");

      logger.d('EVENT transactionsFound $result');
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<void> contractStateChangedCaller(ContractStateChangedEvent event) async {
    try {
      final jsonOutput = jsonEncode(event.toJson());
      logger.d('EVENT contractStateChanged $jsonOutput');

      final controller = await inAppWebViewControllerCompleter.future;
      final result = await controller.evaluateJavascript(source: "window.__dartNotifications.contractStateChanged('$jsonOutput')");

      logger.d('EVENT contractStateChanged $result');
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<void> networkChangedCaller(NetworkChangedEvent event) async {
    try {
      final jsonOutput = jsonEncode(event.toJson());
      logger.d('EVENT networkChanged $jsonOutput');

      final controller = await inAppWebViewControllerCompleter.future;
      final result = await controller.evaluateJavascript(source: "window.__dartNotifications.networkChanged('$jsonOutput')");

      logger.d('EVENT networkChanged $result');
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<void> permissionsChangedCaller(PermissionsChangedEvent event) async {
    try {
      final jsonOutput = jsonEncode(event.toJson());
      logger.d('EVENT permissionsChanged $jsonOutput');

      final controller = await inAppWebViewControllerCompleter.future;
      final result = await controller.evaluateJavascript(source: "window.__dartNotifications.permissionsChanged('$jsonOutput')");

      logger.d('EVENT permissionsChanged $result');
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<void> loggedOutCaller(Object event) async {
    try {
      logger.d('EVENT loggedOut');

      final controller = await inAppWebViewControllerCompleter.future;
      final result = await controller.evaluateJavascript(source: 'window.__dartNotifications.loggedOut()');

      logger.d('EVENT loggedOut $result');
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> codeToTvcHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('codeToTvc args $jsonInput');

      final input = CodeToTvcInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onCodeToTvc(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          codeToTvc: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        codeToTvc: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('codeToTvc result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> decodeEventHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('decodeEvent args $jsonInput');

      final input = DecodeEventInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onDecodeEvent(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          decodeEvent: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        decodeEvent: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('decodeEvent result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> decodeInputHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('decodeInput args $jsonInput');

      final input = DecodeInputInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onDecodeInput(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          decodeInput: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        decodeInput: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('decodeInput result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> decodeOutputHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('decodeOutput args $jsonInput');

      final input = DecodeOutputInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onDecodeOutput(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          decodeOutput: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        decodeOutput: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('decodeOutput result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> decodeTransactionEventsHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('decodeTransactionEvents args $jsonInput');

      final input = DecodeTransactionEventsInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onDecodeTransactionEvents(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          decodeTransactionEvents: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        decodeTransactionEvents: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('decodeTransactionEvents result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> decodeTransactionHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('decodeTransaction args $jsonInput');

      final input = DecodeTransactionInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onDecodeTransaction(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          decodeTransaction: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        decodeTransaction: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('decodeTransaction result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> disconnectHandler(List<dynamic> args) async {
    try {
      providerRequestsBloc.add(
        ProviderRequestsEvent.onDisconnect(
          origin: origin,
        ),
      );
      await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          disconnect: (value) => value.origin == origin,
          orElse: () => false,
        ),
      );

      final jsonOutput = {};
      logger.d('disconnect result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> encodeInternalInputHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('encodeInternalInput args $jsonInput');

      final input = EncodeInternalInputInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onEncodeInternalInput(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          encodeInternalInput: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        encodeInternalInput: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('encodeInternalInput result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> estimateFeesHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('estimateFees args $jsonInput');

      final input = EstimateFeesInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onEstimateFees(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          estimateFees: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        estimateFees: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('estimateFees result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> extractPublicKeyHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('extractPublicKey args $jsonInput');

      final input = ExtractPublicKeyInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onExtractPublicKey(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          extractPublicKey: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        extractPublicKey: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('extractPublicKey result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> getExpectedAddressHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('getExpectedAddress args $jsonInput');

      final input = GetExpectedAddressInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onGetExpectedAddress(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          getExpectedAddress: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        getExpectedAddress: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('getExpectedAddress result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> getFullContractStateHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('getFullContractState args $jsonInput');

      final input = GetFullContractStateInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onGetFullContractState(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          getFullContractState: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        getFullContractState: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('getFullContractState result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> getProviderStateHandler(List<dynamic> args) async {
    try {
      providerRequestsBloc.add(
        ProviderRequestsEvent.onGetProviderState(
          origin: origin,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          getProviderState: (value) => value.origin == origin,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        getProviderState: (origin, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('getProviderState result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> getTransactionsHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('getTransactions args $jsonInput');

      final input = GetTransactionsInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onGetTransactions(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          getTransactions: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        getTransactions: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('getTransactions result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> packIntoCellHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('packIntoCell args $jsonInput');

      final input = PackIntoCellInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onPackIntoCell(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          packIntoCell: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        packIntoCell: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('packIntoCell result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> requestPermissionsHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('requestPermissions args $jsonInput');

      final input = RequestPermissionsInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onRequestPermissions(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          requestPermissions: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        requestPermissions: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('requestPermissions result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> runLocalHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('runLocal args $jsonInput');

      final input = RunLocalInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onRunLocal(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          runLocal: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        runLocal: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('runLocal result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> sendExternalMessageHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('sendExternalMessage args $jsonInput');

      final input = SendExternalMessageInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onSendExternalMessage(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          sendExternalMessage: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        sendExternalMessage: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('sendExternalMessage result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> sendMessageHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('sendMessage args $jsonInput');

      final input = SendMessageInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onSendMessage(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          sendMessage: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        sendMessage: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('sendMessage result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> splitTvcHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('splitTvc args $jsonInput');

      final input = SplitTvcInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onSplitTvc(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          splitTvc: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        splitTvc: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('splitTvc result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> subscribeHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('subscribe args $jsonInput');

      final input = SubscribeInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onSubscribe(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          subscribe: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        subscribe: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('subscribe result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> unpackFromCellHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('unpackFromCell args $jsonInput');

      final input = UnpackFromCellInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onUnpackFromCell(
          origin: origin,
          input: input,
        ),
      );
      final state = await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          unpackFromCell: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final output = state.maybeWhen(
        unpackFromCell: (origin, input, output) => output,
        orElse: () => null,
      )!;

      final jsonOutput = jsonEncode(output.toJson());
      logger.d('unpackFromCell result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> unsubscribeAllHandler(List<dynamic> args) async {
    try {
      providerRequestsBloc.add(
        ProviderRequestsEvent.onUnsubscribeAll(
          origin: origin,
        ),
      );
      await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          unsubscribeAll: (value) => value.origin == origin,
          orElse: () => false,
        ),
      );

      final jsonOutput = {};
      logger.d('unsubscribeAll result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }

  Future<dynamic> unsubscribeHandler(List<dynamic> args) async {
    try {
      final jsonInput = args.first as Map<String, dynamic>;
      logger.d('unsubscribe args $jsonInput');

      final input = UnsubscribeInput.fromJson(jsonInput);

      providerRequestsBloc.add(
        ProviderRequestsEvent.onUnsubscribe(
          origin: origin,
          input: input,
        ),
      );
      await providerRequestsBloc.stream.firstWhere(
        (e) => e.maybeMap(
          unsubscribe: (value) => value.origin == origin && value.input == input,
          orElse: () => false,
        ),
      );

      final jsonOutput = {};
      logger.d('unsubscribe result $jsonOutput');

      return jsonOutput;
    } catch (err, st) {
      logger.e(err, err, st);
    }
  }
}
