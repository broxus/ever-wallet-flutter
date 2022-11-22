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

    WidgetsBinding.instance.addObserver(this);

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
    WidgetsBinding.instance.removeObserver(this);
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

        return Listener(
          onPointerDown: (_) => browserListener.startHolding(),
          onPointerUp: (_) => browserListener.stopHolding(),
          child: BlocProvider<BackButtonEnabledCubit>(
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
            duration: const Duration(milliseconds: 10),
            child: child,
          ),
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
                  applicationNameForUserAgent: 'EverWalletBrowser',
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
