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
import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_app_bar/browser_app_bar.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_app_bar/browser_app_bar_scroll_listener.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_home.dart';
import 'package:ever_wallet/application/main/browser/widgets/events_listener.dart';
import 'package:ever_wallet/application/main/browser/widgets/utils/browser_controller_util.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/data/models/search_history_dto.dart';
import 'package:ever_wallet/data/repositories/search_history_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BrowserTabWidget extends StatefulWidget {
  const BrowserTabWidget({
    required this.tab,
    required this.tabsCubit,
    super.key,
  });

  final BrowserTabNotifier tab;
  final BrowserTabsCubit tabsCubit;

  @override
  State<BrowserTabWidget> createState() => _BrowserTabWidgetState();
}

class _BrowserTabWidgetState extends State<BrowserTabWidget> with WidgetsBindingObserver {
  /// This flag allows to avoid loading all tabs simultaneously.
  /// This flag rising only when tab was loaded with focus or user opened it by clicking in
  /// tabViewer
  final _wasTabOpenByUser = ValueNotifier<bool>(false);

  final isShowWebView = ValueNotifier<bool>(false);
  late final pullToRefreshController = PullToRefreshController(
    onRefresh: () => controller?.refresh(),
  );
  final webViewUpdateController = StreamController<int?>();
  late StreamSubscription subscription;
  late final browserListener = BrowserAppBarScrollListener(pullToRefreshController);
  final urlTextController = TextEditingController();

  /// If controller is null (starting page is aboutPage) then url will be changed by [BrowserTabsCubit]
  /// and controller will be initialized then.
  InAppWebViewController? controller;
  final _controllerCompleter = Completer<InAppWebViewController>();

  @override
  void initState() {
    _updateCurrentUrl(widget.tab.tab.url, false);

    WidgetsBinding.instance.addObserver(this);

    subscription = webViewUpdateController.stream
        .throttleTime(const Duration(seconds: 1))
        .listen((scroll) async {
      _updateTabData(scroll: scroll);
    });

    widget.tab.addListener(_tabChangedListener);
    _tabChangedListener();
    super.initState();
  }

  Future<void> _updateTabData({int? scroll = 0}) async {
    if (isCurrentTabActive) {
      final screehshot = await _takeScreenshot();
      widget.tabsCubit.updateCurrentTabData(scroll, screehshot);
    }
  }

  Future<Uint8List?> _takeScreenshot() async {
    return controller?.takeScreenshot(
      screenshotConfiguration: ScreenshotConfiguration(
        snapshotWidth: 300,
        quality: 5,
        compressFormat: CompressFormat.JPEG,
      ),
    );
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
      // it somehow causes all tabs pause
      // pauseAll();
    }
  }

  bool get isCurrentTabActive => widget.tab.isTabActive;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.tab.removeListener(_tabChangedListener);
    subscription.cancel();
    webViewUpdateController.close();
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

        return Listener(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<BackButtonEnabledCubit>(create: (_) => BackButtonEnabledCubit()),
              BlocProvider<ForwardButtonEnabledCubit>(create: (_) => ForwardButtonEnabledCubit()),
              BlocProvider<ProgressCubit>(create: (_) => ProgressCubit())
            ],
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

                        return AnimatedPositioned(
                          top: show,
                          width: size.width,
                          duration: const Duration(milliseconds: 300),
                          child: appBar(),
                        );
                      },
                    ),
                  ],
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

    if (url != aboutBlankPage) {
      context
          .read<SearchHistoryRepository>()
          .addSearchHistoryEntry(SearchHistoryDto(url: url, openTime: DateTime.now()));
    }
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
        return ValueListenableBuilder<double>(
          valueListenable: browserListener,
          builder: (_, show, child) => AnimatedPadding(
            padding: EdgeInsets.only(top: BrowserAppBarScrollListener.appBarHeight + show),
            duration: const Duration(milliseconds: 300),
            child: child,
          ),
          child: IndexedStack(
            index: isShow ? 0 : 1,
            children: [
              EventsListener(
                tabId: widget.tab.currentIndex,
                controller: _controllerCompleter,
                child: _webViewBuilder(),
              ),
              BrowserHome(changeUrl: (url) => _updateCurrentUrl(url, false)),
            ],
          ),
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
                webViewUpdateController.add(y);
                browserListener.webViewScrolled(y);
              },
              initialUrlRequest: URLRequest(url: WebUri(widget.tab.tab.url)),
              initialSettings: InAppWebViewSettings(
                applicationNameForUserAgent: 'EverWalletBrowser',
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                transparentBackground: true,
                disableDefaultErrorPage: true,
                allowsInlineMediaPlayback: true,
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
              onLoadResource: onLoadResource,
              onReceivedError: (c, r, e) => onReceivedError(c, r, e, context),
              onReceivedHttpError: (c, r, e) => onReceivedHttpError(c, r, e, context),
              onProgressChanged: (c, p) => onProgressChanged(c, p, context),
              onUpdateVisitedHistory: onUpdateVisitedHistory,
              onPermissionRequest: onPermissionRequest,
              shouldOverrideUrlLoading: shouldOverrideUrlLoading,
              onConsoleMessage: onConsoleMessage,
            ),
            orElse: () => Center(
              child: PlatformCircularProgressIndicator(),
            ),
          ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (isCurrentTabActive) {
          resumeAll();
        }
        break;
      case AppLifecycleState.paused:
        pauseAll();
        break;
      default:
        break;
    }
  }

  void onWebViewCreated(BuildContext context, InAppWebViewController controller) {
    browserControllerJavaScriptBind(context, controller, widget.tab.currentIndex);
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

    webViewUpdateController.add(null);
    _updateCurrentUrl(url?.toString(), true);
  }

  void onLoadResource(InAppWebViewController controller, LoadedResource loadedResource) {
    webViewUpdateController.add(null);
  }

  Future<void> onReceivedError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
    BuildContext context,
  ) async {
    _handleError(
      controller,
      request,
      error.description,
      context,
    );
  }

  Future<void> onReceivedHttpError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceResponse errorResponse,
    BuildContext context,
  ) async {
    _handleError(
      controller,
      request,
      errorResponse.reasonPhrase,
      context,
    );
  }

  void _handleError(
    InAppWebViewController controller,
    WebResourceRequest request,
    String? message,
    BuildContext context,
  ) {
    // Skip subrequests
    if (request.isForMainFrame != true) return;

    final webUri = request.url.isValidUri ? request.url : WebUri(aboutBlankPage);

    controller.loadData(
      data: getErrorPage(
        url: webUri,
        message: message ?? AppLocalizations.of(context)!.network_error,
      ),
      baseUrl: webUri,
      historyUrl: webUri,
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

  Future<PermissionResponse?> onPermissionRequest(
    InAppWebViewController controller,
    PermissionRequest permissionRequest,
  ) async =>
      PermissionResponse(
        resources: permissionRequest.resources,
        action: PermissionResponseAction.GRANT,
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

  void _updateUrlControllerValue(Uri url) {
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
      controller?.pause();
    }
  }

  void resume() {
    if (Platform.isAndroid) {
      controller?.resume();
    }
  }

  void pauseTimers() {
    controller?.pauseTimers();
  }

  void resumeTimers() {
    controller?.resumeTimers();
  }
}
