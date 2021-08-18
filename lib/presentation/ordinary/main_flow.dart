import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../router.gr.dart';
import '../design/design.dart';

class MainFlow extends StatefulWidget {
  @override
  MainFlowState createState() => MainFlowState();
}

class MainFlowState extends State<MainFlow> {
  double? safeArea;

  bool _handleAndroidBackButton([bool? stopDefaultButtonEvent, RouteInfo? routeInfo]) {
    try {
      final router = context.innerRouterOf(MainFlowRoute.name)! as TabsRouter;
      final currentIndex = router.activeIndex;
      if (currentIndex == 0) return false;
      router.setActiveIndex(0);
    } catch (e) {
      debugPrint(e.toString());
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(_handleAndroidBackButton);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_handleAndroidBackButton);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => _handleAndroidBackButton(),
        child: AutoTabsScaffold(
          resizeToAvoidBottomInset: false,
          routes: const [
            WalletFlowRoute(),
            SettingsFlowRoute(),
          ],
          extendBody: true,
          animationDuration: const Duration(milliseconds: 150),
          builder: (context, page, animation) => FadeTransition(
            opacity: Tween(begin: 0.5, end: 1.0).animate(animation),
            child: page,
          ),
          bottomNavigationBuilder: (context, router) => CupertinoTheme(
            data: const CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                tabLabelTextStyle: TextStyle(
                  fontFamily: FontFamily.pt,
                  fontSize: 11.0,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            child: SizedBox(
              height: (safeArea ??= context.safeArea.bottom) + kBottomBarHeight,
              child: PlatformNavBar(
                currentIndex: router.activeIndex,
                itemChanged: (index) {
                  if (index == router.activeIndex) {
                    switch (index) {
                      case 0:
                        router.navigate(const WalletFlowRoute());
                        break;
                      case 1:
                        router.navigate(const SettingsFlowRoute());
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
                    icon: Assets.images.svgWallet.svg(
                      width: 24,
                    ),
                    activeIcon: Assets.images.svgWallet.svg(
                      width: 24,
                      color: CrystalColor.fontHeaderDark,
                    ),
                    label: LocaleKeys.wallet_screen_title.tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: Assets.images.svgUser.svg(
                      width: 24,
                    ),
                    activeIcon: Assets.images.svgUser.svg(
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
}
