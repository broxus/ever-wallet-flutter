import 'dart:async';

import 'package:collection/collection.dart';
import 'package:crystal/presentation/main_router/wallet/webview/account_selection.dart';
import 'package:crystal/presentation/main_router/wallet/webview/browser_home_page.dart';
import 'package:crystal/presentation/main_router/wallet/webview/browser_web_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../domain/blocs/account/accounts_bloc.dart';
import '../../../../domain/blocs/misc/bookmarks_bloc.dart';
import '../../../../domain/blocs/provider/approvals_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../../../design/theme.dart';
import 'approvals_listener.dart';
import 'browser_app_bar.dart';
import 'provider_events_callers.dart';

class WebviewPage extends StatefulWidget {
  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  final accountsBloc = getIt.get<AccountsBloc>();
  final approvalsBloc = getIt.get<ApprovalsBloc>();
  final bookmarksBloc = getIt.get<BookmarksBloc>();
  InAppWebViewController? controller;
  late final StreamSubscription disconnectedStreamSubscription;
  late final StreamSubscription transactionsFoundStreamSubscription;
  late final StreamSubscription contractStateChangedStreamSubscription;
  late final StreamSubscription networkChangedStreamSubscription;
  late final StreamSubscription permissionsChangedStreamSubscription;
  late final StreamSubscription loggedOutStreamSubscription;
  final backButtonEnabledNotifier = ValueNotifier<bool>(false);
  final forwardButtonEnabledNotifier = ValueNotifier<bool>(false);
  final addressFieldFocusedNotifier = ValueNotifier<bool>(false);
  final currentPageBookmarkedNotifier = ValueNotifier<bool>(false);
  final progressNotifier = ValueNotifier<int>(100);
  final homePageShownNotifier = ValueNotifier<bool>(true);
  final urlController = TextEditingController();
  final isManaging = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    disconnectedStreamSubscription = disconnectedStream.listen((event) {
      if (controller != null) {
        disconnectedCaller(controller: controller!, event: event);
      }
    });
    transactionsFoundStreamSubscription = transactionsFoundStream.listen((event) {
      if (controller != null) {
        transactionsFoundCaller(
          controller: controller!,
          event: event,
        );
      }
    });
    contractStateChangedStreamSubscription = contractStateChangedStream.listen((event) {
      if (controller != null) {
        contractStateChangedCaller(
          controller: controller!,
          event: event,
        );
      }
    });
    networkChangedStreamSubscription = networkChangedStream.listen((event) {
      if (controller != null) {
        networkChangedCaller(
          controller: controller!,
          event: event,
        );
      }
    });
    permissionsChangedStreamSubscription = permissionsChangedStream.listen((event) {
      if (controller != null) {
        permissionsChangedCaller(
          controller: controller!,
          event: event,
        );
      }
    });
    loggedOutStreamSubscription = loggedOutStream.listen((event) {
      if (controller != null) {
        loggedOutCaller(
          controller: controller!,
          event: event,
        );
      }
    });
  }

  @override
  void dispose() {
    accountsBloc.close();
    approvalsBloc.close();
    backButtonEnabledNotifier.dispose();
    forwardButtonEnabledNotifier.dispose();
    disconnectedStreamSubscription.cancel();
    transactionsFoundStreamSubscription.cancel();
    contractStateChangedStreamSubscription.cancel();
    networkChangedStreamSubscription.cancel();
    permissionsChangedStreamSubscription.cancel();
    loggedOutStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AccountsBloc, AccountsState>(
        bloc: accountsBloc,
        builder: (context, state) => state.maybeWhen(
          ready: (accounts, currentAccount) => currentAccount != null
              ? buildApprovalsListener(
                  accounts: accounts,
                  currentAccount: currentAccount,
                )
              : Center(
                  child: PlatformCircularProgressIndicator(),
                ),
          orElse: () => Center(
            child: PlatformCircularProgressIndicator(),
          ),
        ),
      );

  Widget buildApprovalsListener({
    required List<AssetsList> accounts,
    required AssetsList currentAccount,
  }) =>
      ApprovalsListener(
        address: currentAccount.address,
        publicKey: currentAccount.publicKey,
        walletType: currentAccount.tonWallet.contract,
        child: buildScaffold(
          accounts: accounts,
          currentAccount: currentAccount,
        ),
      );

  Widget buildScaffold({
    required List<AssetsList> accounts,
    required AssetsList currentAccount,
  }) =>
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Padding(
          padding: EdgeInsets.only(bottom: context.safeArea.bottom),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: CrystalColor.iosBackground,
            body: SafeArea(
              bottom: false,
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: Focus(
                  onFocusChange: (value) => addressFieldFocusedNotifier.value = value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildAppBar(
                        currentAccount: currentAccount,
                        accounts: accounts,
                      ),
                      Expanded(
                        child: buildBody(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget buildAppBar({
    required AssetsList currentAccount,
    required List<AssetsList> accounts,
  }) =>
      BrowserAppBar(
        currentAccount: currentAccount,
        urlController: urlController,
        backButtonEnabledNotifier: backButtonEnabledNotifier,
        forwardButtonEnabledNotifier: forwardButtonEnabledNotifier,
        addressFieldFocusedNotifier: addressFieldFocusedNotifier,
        currentPageBookmarkedNotifier: currentPageBookmarkedNotifier,
        progressNotifier: progressNotifier,
        onGoBack: () => controller?.goBack(),
        onGoForward: () => controller?.goForward(),
        onGoHome: () => controller?.openEmptyPage(),
        onAccountButtonTapped: () => onAccountButtonTapped(accounts),
        onRefreshButtonTapped: () => controller?.reload(),
        onBookmarkButtonTapped: onBookmarkButtonTapped,
        onShareButtonTapped: onShareButtonTapped,
        onUrlEntered: (String url) => controller?.parseAndLoadUrl(url),
      );

  void onAccountButtonTapped(List<AssetsList> accounts) => AccountSelection.open(
        context: context,
        accounts: accounts,
        onTap: (String address) async {
          accountsBloc.add(AccountsEvent.setCurrentAccount(address));
          await disconnect(origin: urlController.text);
        },
      );

  Future<void> onBookmarkButtonTapped() async {
    final url = await controller?.getStringifiedUrl();

    if (url == null) {
      return;
    }

    final bookmark = bookmarksBloc.state.firstWhereOrNull((e) => e.url == url);

    if (bookmark == null) {
      bookmarksBloc.add(BookmarksEvent.addBookmark(url));
    } else {
      bookmarksBloc.add(BookmarksEvent.removeBookmark(bookmark));
    }

    final state = await bookmarksBloc.stream.first;

    currentPageBookmarkedNotifier.value = state.firstWhereOrNull((e) => e.url == url.toString()) != null;
  }

  Future<void> onShareButtonTapped() async {
    final url = await controller?.getStringifiedUrl();

    if (url == null) {
      return;
    }

    Share.share(url);
  }

  Widget buildBody() => ValueListenableBuilder<bool>(
        valueListenable: addressFieldFocusedNotifier,
        builder: (context, addressFieldFocusedValue, child) => ValueListenableBuilder<bool>(
          valueListenable: homePageShownNotifier,
          builder: (context, homePageShownValue, child) => Stack(
            fit: StackFit.expand,
            children: [
              Offstage(
                offstage: homePageShownValue,
                child: BrowserWebView(
                  onLoadStop: onLoadStop,
                  onProgressChanged: onProgressChanged,
                ),
              ),
              Offstage(
                offstage: !homePageShownValue,
                child: BrowserHomePage(
                  bookmarksBloc: bookmarksBloc,
                  onBookmarkTapped: (String url) => controller?.parseAndLoadUrl(url),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: addressFieldFocusedValue ? FocusScope.of(context).unfocus : null,
                child: const SizedBox.expand(),
              ),
            ],
          ),
        ),
      );

  Future<void> onLoadStop(
    InAppWebViewController controller,
    Uri? url,
  ) async {
    this.controller = controller;

    backButtonEnabledNotifier.value = await this.controller?.canGoBack() ?? false;
    forwardButtonEnabledNotifier.value = await this.controller?.canGoForward() ?? false;

    if (url != null) {
      homePageShownNotifier.value = url == Uri.parse("about:blank");
      urlController.value = TextEditingValue(
        text: url.toString(),
        selection: TextSelection.collapsed(offset: url.toString().length),
      );

      currentPageBookmarkedNotifier.value =
          bookmarksBloc.state.firstWhereOrNull((e) => e.url == url.toString()) != null;
    }
  }

  Future<void> onProgressChanged(
    InAppWebViewController controller,
    int progress,
  ) async {
    progressNotifier.value = progress;
  }
}

extension on InAppWebViewController {
  Future<void> openEmptyPage() async => loadUrl(urlRequest: URLRequest(url: Uri.parse("about:blank")));

  Future<void> parseAndLoadUrl(String url) async {
    try {
      final parsedUrl = Uri.parse(url);

      if (parsedUrl.toString().isEmpty) {
        return openEmptyPage();
      }

      return loadUrl(
        urlRequest: URLRequest(url: parsedUrl),
      );
    } catch (_) {
      return;
    }
  }

  Future<String?> getStringifiedUrl() async => getUrl().then((value) => value?.toString());
}
