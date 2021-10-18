import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:crystal/domain/blocs/account/accounts_bloc.dart';
import 'package:crystal/injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../logger.dart';
import '../design/design.dart';
import '../router.gr.dart';

class MainRouterPage extends StatefulWidget {
  @override
  MainRouterPageState createState() => MainRouterPageState();
}

class MainRouterPageState extends State<MainRouterPage> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(handleAndroidBackButton);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(handleAndroidBackButton);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => handleAndroidBackButton(),
        child: AutoTabsScaffold(
          resizeToAvoidBottomInset: false,
          lazyLoad: false,
          routes: const [
            WalletRouterRoute(),
            WebviewRoute(),
            SettingsRouterRoute(),
          ],
          extendBody: true,
          animationDuration: const Duration(milliseconds: 150),
          builder: (context, page, animation) => FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1).animate(animation),
            child: page,
          ),
          bottomNavigationBuilder: (context, router) => CupertinoTheme(
            data: const CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                tabLabelTextStyle: TextStyle(
                  fontFamily: FontFamily.pt,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            child: SizedBox(
              height: context.safeArea.bottom + kBottomBarHeight,
              child: PlatformNavBar(
                currentIndex: router.activeIndex,
                itemChanged: (index) async {
                  final exist = await checkForExistingAccount(index);

                  if (!exist) {
                    await showAddAccountDialog();
                    return;
                  }

                  if (index == router.activeIndex) {
                    switch (index) {
                      case 0:
                        router.navigate(const WalletRouterRoute());
                        break;
                      case 1:
                        router.navigate(const WebviewRoute());
                        break;
                      case 2:
                        router.navigate(const SettingsRouterRoute());
                        break;
                    }
                  } else {
                    router.setActiveIndex(index);
                  }
                },
                backgroundColor: CrystalColor.navigationBarBackground,
                material: (context, target) => MaterialNavBarData(
                  selectedItemColor: CrystalColor.fontHeaderDark,
                  unselectedItemColor: const Color(0xFFC4C4C4),
                ),
                cupertino: (context, target) => CupertinoTabBarData(
                  activeColor: CrystalColor.fontHeaderDark,
                  inactiveColor: const Color(0xFFC4C4C4),
                ),
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      Assets.images.wallet.path,
                      width: 24,
                    ),
                    activeIcon: Image.asset(
                      Assets.images.wallet.path,
                      width: 24,
                      color: CrystalColor.fontHeaderDark,
                    ),
                    label: LocaleKeys.wallet_screen_title.tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      Assets.images.browser.path,
                      width: 24,
                    ),
                    activeIcon: Image.asset(
                      Assets.images.browser.path,
                      width: 24,
                      color: CrystalColor.fontHeaderDark,
                    ),
                    label: LocaleKeys.browser_title.tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      Assets.images.user.path,
                      width: 24,
                    ),
                    activeIcon: Image.asset(
                      Assets.images.user.path,
                      width: 24,
                      color: CrystalColor.fontHeaderDark,
                    ),
                    label: LocaleKeys.settings_screen_title.tr(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Future<bool> checkForExistingAccount(int index) async {
    if (index == 1) {
      final state = await getIt.get<AccountsBloc>().stream.firstWhere((e) => e.maybeWhen(
            ready: (accounts, currentAccount) => true,
            orElse: () => false,
          ));

      final exist = state.maybeWhen(
        ready: (accounts, currentAccount) => currentAccount != null,
        orElse: () => false,
      );

      return exist;
    }

    return true;
  }

  Future<void> showAddAccountDialog() async => showPlatformDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => Theme(
          data: ThemeData(),
          child: PlatformAlertDialog(
            title: const Text('Add account'),
            content: const Text('To use the browser you need to add an account first'),
            actions: [
              PlatformDialogAction(
                onPressed: () async {
                  await context.router.pop();

                  final mainRouterRouter = context.router.root.innerRouterOf(MainRouterRoute.name);
                  final walletRouterRouter = mainRouterRouter?.innerRouterOf(WalletRouterRoute.name);

                  mainRouterRouter?.navigate(const WalletRouterRoute());
                  walletRouterRouter?.navigate(const NewAccountRouterRoute());
                },
                cupertino: (_, __) => CupertinoDialogActionData(
                  isDefaultAction: true,
                ),
                child: const Text('Add account'),
              ),
            ],
          ),
        ),
      );

  bool handleAndroidBackButton([bool? stopDefaultButtonEvent, RouteInfo? routeInfo]) {
    try {
      final router = context.innerRouterOf(MainRouterRoute.name)! as TabsRouter;
      final currentIndex = router.activeIndex;
      if (currentIndex == 0) return false;
      router.setActiveIndex(0);
    } catch (err, st) {
      logger.e(err, err, st);
    }

    return true;
  }
}
