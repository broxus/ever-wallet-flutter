import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuple/tuple.dart';

import '../../../../../data/repositories/generic_contracts_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../injection.dart';
import '../../../../../providers/account/accounts_provider.dart';
import '../../../../../providers/account/browser_current_account_provider.dart';
import '../../../../../providers/provider/generic_contracts_state_changes_provider.dart';
import '../../../../../providers/provider/generic_contracts_transactions_provider.dart';
import '../../../../../providers/provider/logged_out_provider.dart';
import '../../../../../providers/provider/network_changes_provider.dart';
import '../../../../../providers/provider/permissions_provider.dart';
import '../../../../design/design.dart';
import '../modals/browser_accounts_modal/show_browser_accounts_modal.dart';
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
  InAppWebViewController? controller;
  late final PullToRefreshController pullToRefreshController;
  final backButtonEnabledNotifier = ValueNotifier<bool>(false);
  final forwardButtonEnabledNotifier = ValueNotifier<bool>(false);
  final addressFieldFocusedNotifier = ValueNotifier<bool>(false);
  final progressNotifier = ValueNotifier<int>(100);
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pullToRefreshController = PullToRefreshController(
      onRefresh: () => controller?.refresh(),
    );
  }

  @override
  void dispose() {
    backButtonEnabledNotifier.dispose();
    forwardButtonEnabledNotifier.dispose();
    addressFieldFocusedNotifier.dispose();
    progressNotifier.dispose();
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue<TransactionsFoundEvent>>(genericContractsTransactionsProvider, (previous, next) {
            final event = next.asData?.value;

            if (event == null) return;

            if (controller == null) return;

            transactionsFoundCaller(
              controller: controller!,
              event: event,
            );
          });

          ref.listen<AsyncValue<ContractStateChangedEvent>>(genericContractsStateChangesProvider, (previous, next) {
            final event = next.asData?.value;

            if (event == null) return;

            if (controller == null) return;

            contractStateChangedCaller(
              controller: controller!,
              event: event,
            );
          });

          ref.listen<AsyncValue<NetworkChangedEvent>>(networkChangesProvider, (previous, next) {
            final event = next.asData?.value;

            if (event == null) return;

            if (controller == null) return;

            networkChangedCaller(
              controller: controller!,
              event: event,
            );
          });

          ref.listen<AsyncValue<List<Tuple2<String, PermissionsChangedEvent>>>>(permissionsProvider,
              (previous, next) async {
            final currentOrigin = await controller?.getCurrentOrigin();

            final event = next.asData?.value.firstWhereOrNull((e) => e.item1 == currentOrigin)?.item2;

            if (event == null) return;

            if (controller == null) return;

            permissionsChangedCaller(
              controller: controller!,
              event: event,
            );
          });

          ref.listen<void>(loggedOutProvider, (previous, next) async {
            if (controller == null) return;

            loggedOutCaller(
              controller: controller!,
            );
          });

          ref.listen<AssetsList?>(
            browserCurrentAccountProvider,
            (previous, next) async {
              final currentOrigin = await controller?.getCurrentOrigin();

              if (currentOrigin == null) return;

              await getIt.get<PermissionsRepository>().deletePermissions(currentOrigin);

              await getIt.get<GenericContractsRepository>().clear();
            },
          );

          final accounts = ref.watch(accountsProvider).asData?.value ?? [];
          final currentAccount = ref.watch(browserCurrentAccountProvider);

          return buildApprovalsListener(
            accounts: accounts,
            currentAccount: currentAccount,
          );
        },
      );

  Widget buildApprovalsListener({
    required List<AssetsList> accounts,
    required AssetsList? currentAccount,
  }) =>
      currentAccount != null
          ? ApprovalsListener(
              address: currentAccount.address,
              publicKey: currentAccount.publicKey,
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
      Consumer(
        builder: (context, ref, child) => BrowserAppBar(
          currentAccount: currentAccount,
          urlController: urlController,
          backButtonEnabledNotifier: backButtonEnabledNotifier,
          forwardButtonEnabledNotifier: forwardButtonEnabledNotifier,
          addressFieldFocusedNotifier: addressFieldFocusedNotifier,
          progressNotifier: progressNotifier,
          onGoBack: () => controller?.goBack(),
          onGoForward: () => controller?.goForward(),
          onGoHome: () => controller?.openInitialPage(),
          onAccountButtonTapped: () => onAccountButtonTapped(read: ref.read, accounts: accounts),
          onRefreshButtonTapped: () => controller?.reload(),
          onShareButtonTapped: onShareButtonTapped,
          onUrlEntered: (String url) => controller?.parseAndLoadUrl(url),
        ),
      );

  void onAccountButtonTapped({
    required Reader read,
    required List<AssetsList> accounts,
  }) =>
      showBrowserAccountsModal(
        context: context,
        accounts: accounts,
        onTap: (String address) => read(browserCurrentAccountProvider.notifier).setCurrent(address),
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
