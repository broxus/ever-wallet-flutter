import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/main/browser/back_button_enabled_cubit.dart';
import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tabs_cubit/browser_tabs_cubit.dart';
import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tabs_cubit/browser_tabs_notifiers.dart';
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
import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_app_bar/browser_app_bar.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_app_bar/browser_app_bar_scroll_listener.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_home.dart';
import 'package:ever_wallet/application/main/browser/widgets/events_listener.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/data/models/search_history_dto.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/approvals_repository.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/search_history_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BrowserTabWidget extends StatefulWidget {
  const BrowserTabWidget({
    required this.tab,
    required this.tabsCubit,
    Key? key,
  }) : super(key: key);

  final BrowserTabNotifier tab;
  final BrowserTabsCubit tabsCubit;

  @override
  State<BrowserTabWidget> createState() => _BrowserTabWidgetState();
}

class _BrowserTabWidgetState extends State<BrowserTabWidget> {
  /// This flag allows to avoid loading all tabs simultaneously.
  /// This flag rising only when tab was loaded with focus or user opened it by clicking in
  /// tabViewer
  final _wasTabOpenByUser = ValueNotifier<bool>(false);

  final isShowWebView = ValueNotifier<bool>(false);
  late final pullToRefreshController = PullToRefreshController(
    onRefresh: () => controller?.refresh(),
  );
  final webViewScrollController = StreamController<int>();
  late StreamSubscription subscription;
  final browserListener = BrowserAppBarScrollListener();
  final urlTextController = TextEditingController();

  /// If controller is null (starting page is aboutPage) then url will be changed by [BrowserTabsCubit]
  /// and controller will be initialized then.
  InAppWebViewController? controller;
  final _controllerCompleter = Completer<InAppWebViewController>();

  @override
  void initState() {
    _updateCurrentUrl(widget.tab.tab.url, false);

    subscription = webViewScrollController.stream
        .throttleTime(const Duration(seconds: 10))
        .listen((scroll) async {
      if (isCurrentTabActive) {
        final size = MediaQuery.of(context).size;
        final screenshot = await controller!.takeScreenshot(
          screenshotConfiguration: ScreenshotConfiguration(
            quality: 5,
            compressFormat: CompressFormat.JPEG,
            rect: InAppWebViewRect(
              height: size.height,
              width: size.width,
              x: 0,
              y: 0,
            ),
          ),
        );
        // average size of image ~10-20kb
        widget.tabsCubit.updateCurrentTabData(scroll, screenshot);
      }
    });

    widget.tab.addListener(_tabChangedListener);
    _tabChangedListener();
    super.initState();
  }

  void _tabChangedListener() {
    if (!_wasTabOpenByUser.value && isCurrentTabActive) {
      _wasTabOpenByUser.value = true;
    }

    if (widget.tab.tab.url != aboutBlankPage) {
      isShowWebView.value = true;
    } else {
      isShowWebView.value = false;
    }

    if (isCurrentTabActive) {
      resumeAll();
    } else {
      pauseAll();
    }
  }

  bool get isCurrentTabActive => widget.tab.isTabActive;

  @override
  void dispose() {
    widget.tab.removeListener(_tabChangedListener);
    subscription.cancel();
    webViewScrollController.close();
    browserListener.dispose();
    urlTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _wasTabOpenByUser,
      builder: (_, wasOpened, __) {
        if (!wasOpened) return const SizedBox();

        return BlocProvider<BackButtonEnabledCubit>(
          create: (context) => BackButtonEnabledCubit(),
          child: BlocProvider<ForwardButtonEnabledCubit>(
            create: (context) => ForwardButtonEnabledCubit(),
            child: BlocProvider<ProgressCubit>(
              create: (context) => ProgressCubit(),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: ColorsRes.white,
                body: SafeArea(
                  child: Stack(
                    children: [
                      Positioned.fill(child: body()),
                      ValueListenableBuilder<double>(
                        valueListenable: browserListener,
                        builder: (_, show, __) {
                          final size = MediaQuery.of(context).size;

                          return Positioned(
                            top: show,
                            width: size.width,
                            child: appBar(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// if [isControllerChange] true then update only text and browserTab data
  /// else update controllers url (ex: it was changed via search bar)
  void _updateCurrentUrl(String? url, bool isControllerChange) {
    if (url == null) return;

    if (controller != null && !isControllerChange) {
      controller!.tryLoadUrl(url);
    }
    _updateUrlControllerValue(Uri.parse(url));
    widget.tabsCubit.updateCurrentTab(url);
    context
        .read<SearchHistoryRepository>()
        .addSearchHistoryEntry(SearchHistoryDto(url: url, openTime: DateTime.now()));
  }

  Widget appBar() => BrowserAppBar(
        controller: _controllerCompleter,
        key: browserListener.browserFlexibleKey,
        tabsCubit: widget.tabsCubit,
        urlController: urlTextController,
        changeUrl: (url) => _updateCurrentUrl(url, false),
        tabsCount: widget.tabsCubit.tabsCount,
      );

  Widget body() {
    return ValueListenableBuilder<bool>(
      valueListenable: isShowWebView,
      builder: (_, isShow, __) {
        return Column(
          children: [
            // This displays separately from Expanded to reduce webview re-render
            ValueListenableBuilder<double>(
              valueListenable: browserListener,
              builder: (_, show, __) => SizedBox(
                height: BrowserAppBarScrollListener.appBarHeight + show,
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: isShow ? 0 : 1,
                children: [
                  EventsListener(
                    controller: _controllerCompleter,
                    child: _webViewBuilder(),
                  ),
                  BrowserHome(changeUrl: (url) => _updateCurrentUrl(url, false)),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget _webViewBuilder() {
    return FutureProvider<AsyncValue<String>>(
      create: (context) => rootBundle
          .loadString('packages/nekoton_flutter/assets/js/main.js')
          .then((value) => AsyncValue.ready(value)),
      initialData: const AsyncValue.loading(),
      catchError: (context, error) => AsyncValue.error(error),
      builder: (context, child) => context.watch<AsyncValue<String>>().maybeWhen(
            ready: (value) => InAppWebView(
              onScrollChanged: (_, __, y) {
                webViewScrollController.add(y);
                browserListener.webViewScrolled(y);
              },
              initialUrlRequest: URLRequest(url: Uri.parse(widget.tab.tab.url)),
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
                UserScript(
                  source: 'window.scrollBy(0, ${widget.tab.tab.lastScrollPosition});',
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                ),
              ]),
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (c) => onWebViewCreated(context, c),
              onLoadStart: onLoadStart,
              onLoadStop: (controller, url) => onLoadStop(controller, url, context),
              onLoadError: onLoadError,
              onLoadHttpError: onLoadError,
              onProgressChanged: (c, p) => onProgressChanged(c, p, context),
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
  }

  void onWebViewCreated(BuildContext context, InAppWebViewController controller) {
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

    this.controller = controller;
    _controllerCompleter.complete(controller);
  }

  void onLoadStart(
    InAppWebViewController controller,
    Uri? url,
  ) =>
      _updateCurrentUrl(url?.toString(), true);

  Future<void> onLoadStop(
    InAppWebViewController controller,
    Uri? url,
    BuildContext context,
  ) async {
    pullToRefreshController.endRefreshing();
    if (!mounted) return;

    final canGoBack = await controller.canGoBack();
    final canGoForward = await controller.canGoForward();

    if (!mounted) return;

    context.read<BackButtonEnabledCubit>().setIsEnabled(canGoBack);
    context.read<ForwardButtonEnabledCubit>().setIsEnabled(canGoForward);

    webViewScrollController.add(0);
    _updateCurrentUrl(url?.toString(), true);
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
    BuildContext context,
  ) {
    if (progress == 100) pullToRefreshController.endRefreshing();
    context.read<ProgressCubit>().setProgress(progress);
  }

  void onUpdateVisitedHistory(
    InAppWebViewController controller,
    Uri? url,
    bool? androidIsReload,
  ) =>
      _updateCurrentUrl(url?.toString(), true);

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

  void _updateUrlControllerValue(Uri? url) {
    var text = url.toString();

    if (url == Uri.parse(aboutBlankPage)) {
      text = '';
    }

    urlTextController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void pauseAll() {
    pause();
    pauseTimers();
  }

  void resumeAll() {
    resume();
    resumeTimers();
  }

  void pause() {
    if (Platform.isAndroid) {
      controller?.android.pause();
    }
  }

  void resume() {
    if (Platform.isAndroid) {
      controller?.android.resume();
    }
  }

  void pauseTimers() {
    controller?.pauseTimers();
  }

  void resumeTimers() {
    controller?.resumeTimers();
  }
}
