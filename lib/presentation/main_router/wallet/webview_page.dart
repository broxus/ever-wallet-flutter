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

  @override
  void initState() {
    super.initState();
    tonWalletInfoBloc = getIt.get<TonWalletInfoBloc>(param1: widget.address);
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
    final jsonOutput = jsonEncode(event.toJson());

    final controller = await inAppWebViewControllerCompleter.future;
    controller.evaluateJavascript(source: 'disconnected($jsonOutput)');
  }

  Future<void> transactionsFoundCaller(TransactionsFoundEvent event) async {
    final jsonOutput = jsonEncode(event.toJson());

    final controller = await inAppWebViewControllerCompleter.future;
    controller.evaluateJavascript(source: 'transactionsFound($jsonOutput)');
  }

  Future<void> contractStateChangedCaller(ContractStateChangedEvent event) async {}

  Future<void> networkChangedCaller(NetworkChangedEvent event) async {
    final jsonOutput = jsonEncode(event.toJson());

    final controller = await inAppWebViewControllerCompleter.future;
    controller.evaluateJavascript(source: 'networkChanged($jsonOutput)');
  }

  Future<void> permissionsChangedCaller(PermissionsChangedEvent event) async {
    final jsonOutput = jsonEncode(event.toJson());

    final controller = await inAppWebViewControllerCompleter.future;
    controller.evaluateJavascript(source: 'permissionsChanged($jsonOutput)');
  }

  Future<void> loggedOutCaller(Object event) async {
    final controller = await inAppWebViewControllerCompleter.future;
    controller.evaluateJavascript(source: 'loggedOut()');
  }

  Future<dynamic> codeToTvcHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = CodeToTvcInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = CodeToTvcOutput(tvc: "tvc");
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> decodeEventHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = DecodeEventInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = DecodeEventOutput(
      event: "event",
      data: {
        "data": "data",
      },
    );
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> decodeInputHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = DecodeInputInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = DecodeInputOutput(
      method: "method",
      input: {
        "input": "input",
      },
    );
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> decodeOutputHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = DecodeOutputInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = DecodeOutputOutput(
      method: "method",
      output: {
        "output": "output",
      },
    );
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> decodeTransactionEventsHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = DecodeTransactionEventsInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = DecodeTransactionEventsOutput(events: []);
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> decodeTransactionHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = DecodeTransactionInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = DecodeTransactionOutput(
      method: "method",
      input: {
        "input": "input",
      },
      output: {
        "output": "output",
      },
    );
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> disconnectHandler(List<dynamic> args) async {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("disconnected");
  }

  Future<dynamic> encodeInternalInputHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = EncodeInternalInputInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = EncodeInternalInputOutput(boc: "boc");
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> estimateFeesHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = EstimateFeesInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = EstimateFeesOutput(fees: "fees");
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> extractPublicKeyHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = ExtractPublicKeyInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = ExtractPublicKeyOutput(publicKey: "publicKey");
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> getExpectedAddressHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = GetExpectedAddressInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = GetExpectedAddressOutput(address: "address");
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> getFullContractStateHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = GetFullContractStateInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = GetFullContractStateOutput(
      state: FullContractState(
        balance: "balance",
        genTimings: GenTimings(
          genLt: "genLt",
          genUtime: 0,
        ),
        lastTransactionId: LastTransactionId(
          isExact: true,
          lt: "lt",
          hash: "hash",
        ),
        isDeployed: true,
        boc: "boc",
      ),
    );
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> getProviderStateHandler(List<dynamic> args) async {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("get provider state");

    final output = GetProviderStateOutput(
      version: "version",
      numericVersion: 0,
      selectedConnection: "selectedConnection",
      permissions: Permissions(
        tonClient: true,
        accountInteraction: AccountInteraction(
          address: "address",
          publicKey: "publicKey",
          contractType: WalletContractType.values.first,
        ),
      ),
      subscriptions: {
        "address": const ContractUpdatesSubscription(
          state: true,
          transactions: true,
        ),
      },
    );
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> getTransactionsHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = GetTransactionsInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    final output = GetTransactionsOutput(
      transactions: [
        Transaction(
          id: const TransactionId(
            lt: "lt",
            hash: "hash",
          ),
          prevTransactionId: const TransactionId(
            lt: "lt",
            hash: "hash",
          ),
          createdAt: 1,
          aborted: true,
          origStatus: AccountStatus.values.first,
          endStatus: AccountStatus.values.first,
          totalFees: "totalFees",
          inMessage: const Message(
            src: "src",
            dst: "dst",
            value: "value",
            bounce: true,
            bounced: true,
            body: "body",
            bodyHash: "bodyHash",
          ),
          outMessages: const [
            Message(
              src: "src",
              dst: "dst",
              value: "value",
              bounce: true,
              bounced: true,
              body: "body",
              bodyHash: "bodyHash",
            ),
          ],
        ),
      ],
      continuation: const TransactionId(
        lt: "lt",
        hash: "hash",
      ),
    );
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> packIntoCellHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = PackIntoCellInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = PackIntoCellOutput(boc: "boc");
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> requestPermissionsHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = RequestPermissionsInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    final output = RequestPermissionsOutput(
      tonClient: true,
      accountInteraction: AccountInteraction(
        address: "address",
        publicKey: "publicKey",
        contractType: WalletContractType.values.first,
      ),
    );
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> runLocalHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = RunLocalInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = RunLocalOutput(output: {"output": "output"}, code: 0);
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> sendExternalMessageHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = SendExternalMessageInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    final output = SendExternalMessageOutput(
      transaction: Transaction(
        id: const TransactionId(
          lt: "lt",
          hash: "hash",
        ),
        prevTransactionId: const TransactionId(
          lt: "lt",
          hash: "hash",
        ),
        createdAt: 1,
        aborted: true,
        origStatus: AccountStatus.values.first,
        endStatus: AccountStatus.values.first,
        totalFees: "totalFees",
        inMessage: const Message(
          src: "src",
          dst: "dst",
          value: "value",
          bounce: true,
          bounced: true,
          body: "body",
          bodyHash: "bodyHash",
        ),
        outMessages: [
          const Message(
            src: "src",
            dst: "dst",
            value: "value",
            bounce: true,
            bounced: true,
            body: "body",
            bodyHash: "bodyHash",
          ),
        ],
      ),
      output: {
        "output": "output",
      },
    );
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> sendMessageHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = SendMessageInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    final output = SendMessageOutput(
      transaction: Transaction(
        id: const TransactionId(
          lt: "lt",
          hash: "hash",
        ),
        prevTransactionId: const TransactionId(
          lt: "lt",
          hash: "hash",
        ),
        createdAt: 1,
        aborted: true,
        origStatus: AccountStatus.values.first,
        endStatus: AccountStatus.values.first,
        totalFees: "totalFees",
        inMessage: const Message(
          src: "src",
          dst: "dst",
          value: "value",
          bounce: true,
          bounced: true,
          body: "body",
          bodyHash: "bodyHash",
        ),
        outMessages: [
          const Message(
            src: "src",
            dst: "dst",
            value: "value",
            bounce: true,
            bounced: true,
            body: "body",
            bodyHash: "bodyHash",
          ),
        ],
      ),
    );
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> splitTvcHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = SplitTvcInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = SplitTvcOutput(
      data: "data",
      code: "code",
    );
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> subscribeHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = SubscribeInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = SubscribeOutput(
      state: true,
      transactions: true,
    );
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> unpackFromCellHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = UnpackFromCellInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());

    const output = UnpackFromCellOutput(data: {"data": "data"});
    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  }

  Future<dynamic> unsubscribeAllHandler(List<dynamic> args) async {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("unsubscribed all");
  }

  Future<dynamic> unsubscribeHandler(List<dynamic> args) async {
    final jsonInput = jsonDecode(args.first as String) as Map<String, dynamic>;
    final input = UnsubscribeInput.fromJson(jsonInput);

    await Future.delayed(const Duration(seconds: 1));
    debugPrint(input.toString());
    debugPrint("unsubscribed");
  }
}
