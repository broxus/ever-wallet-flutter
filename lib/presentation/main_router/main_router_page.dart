import 'package:back_button_interceptor/back_button_interceptor.dart';
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
          routes: const [
            WalletRouterRoute(),
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
                itemChanged: (index) {
                  if (index == router.activeIndex) {
                    switch (index) {
                      case 0:
                        router.navigate(const WalletRouterRoute());
                        break;
                      case 1:
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
