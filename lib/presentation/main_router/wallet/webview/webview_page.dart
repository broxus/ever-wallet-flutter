import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../domain/blocs/account/accounts_bloc.dart';
import '../../../../domain/blocs/provider/approvals_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../../../design/theme.dart';
import 'account_selection.dart';
import 'approvals_listener.dart';
import 'browser_app_bar.dart';
import 'browser_web_view.dart';
import 'controller_extensions.dart';
import 'provider_events_callers.dart';

class WebviewPage extends StatefulWidget {
  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  final approvalsBloc = getIt.get<ApprovalsBloc>();
  InAppWebViewController? controller;
  late final PullToRefreshController pullToRefreshController;
  late final StreamSubscription disconnectedStreamSubscription;
  late final StreamSubscription transactionsFoundStreamSubscription;
  late final StreamSubscription contractStateChangedStreamSubscription;
  late final StreamSubscription networkChangedStreamSubscription;
  late final StreamSubscription permissionsChangedStreamSubscription;
  late final StreamSubscription loggedOutStreamSubscription;
  final backButtonEnabledNotifier = ValueNotifier<bool>(false);
  final forwardButtonEnabledNotifier = ValueNotifier<bool>(false);
  final addressFieldFocusedNotifier = ValueNotifier<bool>(false);
  final progressNotifier = ValueNotifier<int>(100);
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () => controller?.refresh(),
    );
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
    approvalsBloc.close();
    disconnectedStreamSubscription.cancel();
    transactionsFoundStreamSubscription.cancel();
    contractStateChangedStreamSubscription.cancel();
    networkChangedStreamSubscription.cancel();
    permissionsChangedStreamSubscription.cancel();
    loggedOutStreamSubscription.cancel();
    backButtonEnabledNotifier.dispose();
    forwardButtonEnabledNotifier.dispose();
    addressFieldFocusedNotifier.dispose();
    progressNotifier.dispose();
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AccountsBloc, AccountsState>(
        bloc: context.watch<AccountsBloc>(),
        builder: (context, state) => buildApprovalsListener(
          accounts: state.accounts,
          currentAccount: state.currentAccount,
        ),
      );

  Widget buildApprovalsListener({
    required List<AssetsList> accounts,
    required AssetsList? currentAccount,
  }) =>
      currentAccount != null
          ? ApprovalsListener(
              address: currentAccount.address,
              publicKey: currentAccount.publicKey,
              walletType: currentAccount.tonWallet.contract,
              child: buildScaffold(
                accounts: accounts,
                currentAccount: currentAccount,
              ),
            )
          : buildScaffold(
              accounts: accounts,
              currentAccount: currentAccount,
            );

  Widget buildScaffold({
    required List<AssetsList> accounts,
    AssetsList? currentAccount,
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
    required List<AssetsList> accounts,
    AssetsList? currentAccount,
  }) =>
      BrowserAppBar(
        currentAccount: currentAccount,
        urlController: urlController,
        backButtonEnabledNotifier: backButtonEnabledNotifier,
        forwardButtonEnabledNotifier: forwardButtonEnabledNotifier,
        addressFieldFocusedNotifier: addressFieldFocusedNotifier,
        progressNotifier: progressNotifier,
        onGoBack: () => controller?.goBack(),
        onGoForward: () => controller?.goForward(),
        onGoHome: () => controller?.openInitialPage(),
        onAccountButtonTapped: () => onAccountButtonTapped(accounts),
        onRefreshButtonTapped: () => controller?.reload(),
        onShareButtonTapped: onShareButtonTapped,
        onUrlEntered: (String url) => controller?.parseAndLoadUrl(url),
      );

  void onAccountButtonTapped(List<AssetsList> accounts) => AccountSelection.open(
        context: context,
        accounts: accounts,
        onTap: (String address) async {
          context.read<AccountsBloc>().add(AccountsEvent.setCurrent(address));
          await disconnect(origin: (await controller!.getCurrentOrigin())!);
        },
      );

  Future<void> onShareButtonTapped() async {
    final url = await controller?.getStringifiedUrl();

    if (url == null) {
      return;
    }

    Share.share(url);
  }

  Widget buildBody() => ValueListenableBuilder<bool>(
        valueListenable: addressFieldFocusedNotifier,
        builder: (context, addressFieldFocusedValue, child) => Stack(
          fit: StackFit.expand,
          children: [
            BrowserWebView(
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: onWebViewCreated,
              onLoadStart: onLoadStart,
              onLoadStop: onLoadStop,
              onProgressChanged: onProgressChanged,
              onUpdateVisitedHistory: onUpdateVisitedHistory,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: addressFieldFocusedValue ? FocusScope.of(context).unfocus : null,
              child: const SizedBox.expand(),
            ),
          ],
        ),
      );

  Future<void> onWebViewCreated(InAppWebViewController controller) async {
    this.controller = controller;
  }

  Future<void> onLoadStart(
    InAppWebViewController controller,
    Uri? url,
  ) async {
    urlController.value = TextEditingValue(text: url.toString());
  }

  Future<void> onLoadStop(
    InAppWebViewController controller,
    Uri? url,
  ) async {
    backButtonEnabledNotifier.value = await this.controller?.canGoBack() ?? false;
    forwardButtonEnabledNotifier.value = await this.controller?.canGoForward() ?? false;

    if (url != null) {
      urlController.value = TextEditingValue(
        text: url.toString(),
        selection: TextSelection.collapsed(offset: url.toString().length),
      );
    }
  }

  Future<void> onProgressChanged(
    InAppWebViewController controller,
    int progress,
  ) async {
    progressNotifier.value = progress;
  }

  Future<void> onUpdateVisitedHistory(
    InAppWebViewController controller,
    Uri? url,
    bool? androidIsReload,
  ) async {
    urlController.value = TextEditingValue(text: url.toString());
  }
}
