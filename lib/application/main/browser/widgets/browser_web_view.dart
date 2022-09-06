import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/main/browser/back_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/forward_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/progress_cubit.dart';
import 'package:ever_wallet/application/main/browser/requests/add_asset_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/change_account_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/code_to_tvc_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/decode_event_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/decode_input_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/decode_output_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/decode_transaction_events_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/decode_transaction_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/decrypt_data_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/disconnect_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/encode_internal_input_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/encrypt_data_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/estimate_fees_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/extract_public_key_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_accounts_by_code_hash_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_boc_hash_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_expected_address_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_full_contract_state_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_provider_state_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_transaction_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/get_transactions_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/pack_into_cell_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/request_permissions_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/run_local_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/send_external_message_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/send_message_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/send_unsigned_external_message_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/sign_data_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/sign_data_raw_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/split_tvc_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/subscribe_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/unpack_from_cell_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/unsubscribe_all_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/unsubscribe_handler.dart';
import 'package:ever_wallet/application/main/browser/requests/verify_signature_handler.dart';
import 'package:ever_wallet/application/main/browser/url_cubit.dart';
import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_app_bar/browser_app_bar_scroll_listener.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BrowserWebView extends StatefulWidget {
  final Completer<InAppWebViewController> controller;
  final TextEditingController urlController;
  final BrowserAppBarScrollListener browserListener;

  const BrowserWebView({
    Key? key,
    required this.controller,
    required this.urlController,
    required this.browserListener,
  }) : super(key: key);

  @override
  State<BrowserWebView> createState() => _BrowserWebViewState();
}

class _BrowserWebViewState extends State<BrowserWebView> {
  late final pullToRefreshController = PullToRefreshController(
    onRefresh: () => widget.controller.future.then((v) => v.refresh()),
  );

  @override
  Widget build(BuildContext context) => FutureProvider<AsyncValue<String>>(
        create: (context) => rootBundle
            .loadString('packages/nekoton_flutter/assets/js/main.js')
            .then((value) => AsyncValue.ready(value)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, child) => context.watch<AsyncValue<String>>().maybeWhen(
              ready: (value) => InAppWebView(
                onScrollChanged: (_, __, y) => widget.browserListener.webViewScrolled(y),
                initialUrlRequest: URLRequest(url: Uri.parse(aboutBlankPage)),
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
                    source: value,
                    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                  ),
                ]),
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: onWebViewCreated,
                onLoadStart: onLoadStart,
                onLoadStop: (controller, url) => onLoadStop(controller, url),
                onLoadError: onLoadError,
                onLoadHttpError: onLoadError,
                onProgressChanged: onProgressChanged,
                onUpdateVisitedHistory: onUpdateVisitedHistory,
                androidOnPermissionRequest: androidOnPermissionRequest,
                shouldOverrideUrlLoading: shouldOverrideUrlLoading,
                onConsoleMessage: onConsoleMessage,
              ),
              orElse: () => Center(
                child: PlatformCircularProgressIndicator(),
              ),
            ),
      );

  void onWebViewCreated(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'requestPermissions',
      callback: (args) => requestPermissionsHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        approvalsRepository: context.read<ApprovalsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'changeAccount',
      callback: (args) => changeAccountHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        approvalsRepository: context.read<ApprovalsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'disconnect',
      callback: (args) => disconnectHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        genericContractsRepository: context.read<GenericContractsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'subscribe',
      callback: (args) => subscribeHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        genericContractsRepository: context.read<GenericContractsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'unsubscribe',
      callback: (args) => unsubscribeHandler(
        controller: controller,
        args: args,
        genericContractsRepository: context.read<GenericContractsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'unsubscribeAll',
      callback: (args) => unsubscribeAllHandler(
        controller: controller,
        args: args,
        genericContractsRepository: context.read<GenericContractsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getProviderState',
      callback: (args) => getProviderStateHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        genericContractsRepository: context.read<GenericContractsRepository>(),
        transportRepository: context.read<TransportRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getFullContractState',
      callback: (args) => getFullContractStateHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        transportRepository: context.read<TransportRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getAccountsByCodeHash',
      callback: (args) => getAccountsByCodeHashHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        transportRepository: context.read<TransportRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getTransactions',
      callback: (args) => getTransactionsHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        transportRepository: context.read<TransportRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getTransaction',
      callback: (args) => getTransactionHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        transportRepository: context.read<TransportRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'runLocal',
      callback: (args) => runLocalHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        transportRepository: context.read<TransportRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getExpectedAddress',
      callback: (args) => getExpectedAddressHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'getBocHash',
      callback: (args) => getBocHashHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'packIntoCell',
      callback: (args) => packIntoCellHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'unpackFromCell',
      callback: (args) => unpackFromCellHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'extractPublicKey',
      callback: (args) => extractPublicKeyHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'codeToTvc',
      callback: (args) => codeToTvcHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'splitTvc',
      callback: (args) => splitTvcHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'encodeInternalInput',
      callback: (args) => encodeInternalInputHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeInput',
      callback: (args) => decodeInputHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeEvent',
      callback: (args) => decodeEventHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeOutput',
      callback: (args) => decodeOutputHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeTransaction',
      callback: (args) => decodeTransactionHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decodeTransactionEvents',
      callback: (args) => decodeTransactionEventsHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'verifySignature',
      callback: (args) => verifySignatureHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'sendUnsignedExternalMessage',
      callback: (args) => sendUnsignedExternalMessageHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        transportRepository: context.read<TransportRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'addAsset',
      callback: (args) => addAssetHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        approvalsRepository: context.read<ApprovalsRepository>(),
        transportRepository: context.read<TransportRepository>(),
        accountsRepository: context.read<AccountsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'signData',
      callback: (args) => signDataHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        approvalsRepository: context.read<ApprovalsRepository>(),
        keysRepository: context.read<KeysRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'signDataRaw',
      callback: (args) => signDataRawHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        approvalsRepository: context.read<ApprovalsRepository>(),
        keysRepository: context.read<KeysRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'encryptData',
      callback: (args) => encryptDataHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        approvalsRepository: context.read<ApprovalsRepository>(),
        keysRepository: context.read<KeysRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'decryptData',
      callback: (args) => decryptDataHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        approvalsRepository: context.read<ApprovalsRepository>(),
        keysRepository: context.read<KeysRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'estimateFees',
      callback: (args) => estimateFeesHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        tonWalletsRepository: context.read<TonWalletsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'sendMessage',
      callback: (args) => sendMessageHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        approvalsRepository: context.read<ApprovalsRepository>(),
        keysRepository: context.read<KeysRepository>(),
        tonWalletsRepository: context.read<TonWalletsRepository>(),
      ),
    );

    controller.addJavaScriptHandler(
      handlerName: 'sendExternalMessage',
      callback: (args) => sendExternalMessageHandler(
        controller: controller,
        args: args,
        permissionsRepository: context.read<PermissionsRepository>(),
        approvalsRepository: context.read<ApprovalsRepository>(),
        genericContractsRepository: context.read<GenericContractsRepository>(),
        keysRepository: context.read<KeysRepository>(),
        tonWalletsRepository: context.read<TonWalletsRepository>(),
      ),
    );

    widget.controller.complete(controller);
  }

  void onLoadStart(
    InAppWebViewController controller,
    Uri? url,
  ) =>
      updateUrlControllerValue(url);

  Future<void> onLoadStop(
    InAppWebViewController controller,
    Uri? url,
  ) async {
    pullToRefreshController.endRefreshing();

    context.read<UrlCubit>().setUrl(url?.toString());

    final canGoBack = await controller.canGoBack();
    final canGoForward = await controller.canGoForward();

    if (!mounted) return;

    context.read<BackButtonEnabledCubit>().setIsEnabled(canGoBack);
    context.read<ForwardButtonEnabledCubit>().setIsEnabled(canGoForward);

    updateUrlControllerValue(url);
  }

  Future<void> onLoadError(
    InAppWebViewController controller,
    Uri? url,
    int code,
    String message,
  ) async {
    if (Platform.isIOS && code == -999) return;

    final errorUrl = url ?? Uri.parse(aboutBlankPage);

    controller.loadData(
      data: getErrorPage(url: errorUrl, message: message),
      baseUrl: errorUrl,
      historyUrl: errorUrl,
    );
  }

  void onProgressChanged(
    InAppWebViewController controller,
    int progress,
  ) {
    if (progress == 100) pullToRefreshController.endRefreshing();
    context.read<ProgressCubit>().setProgress(progress);
  }

  void onUpdateVisitedHistory(
    InAppWebViewController controller,
    Uri? url,
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

      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);

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

    if (url == Uri.parse(aboutBlankPage)) {
      text = '';
    } else {
      context.read<UrlCubit>().setUrl(text);
    }
    widget.urlController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
