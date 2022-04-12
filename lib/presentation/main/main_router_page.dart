import 'package:auto_route/auto_route.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../logger.dart';
import '../../generated/assets.gen.dart';
import '../../generated/codegen_loader.g.dart';
import '../../generated/fonts.gen.dart';
import '../common/theme.dart';
import '../router.gr.dart';

class MainRouterPage extends StatefulWidget {
  const MainRouterPage({Key? key}) : super(key: key);

  @override
  _MainRouterPageState createState() => _MainRouterPageState();
}

class _MainRouterPageState extends State<MainRouterPage> {
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
          resizeToAvoidBottomInset: true,
          lazyLoad: false,
          routes: const [
            WalletRoute(),
            BrowserRoute(),
            ProfileRouterRoute(),
          ],
          animationDuration: Duration.zero,
          builder: (context, page, animation) => page,
          bottomNavigationBuilder: (context, router) => bottomNavigationBar(router),
        ),
      );

  Widget bottomNavigationBar(TabsRouter router) => CupertinoTheme(
        data: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            tabLabelTextStyle: TextStyle(
              fontFamily: FontFamily.pt,
              fontSize: 11,
              letterSpacing: 0.2,
            ),
          ),
        ),
        child: Consumer(
          builder: (context, ref, child) => PlatformNavBar(
            currentIndex: router.activeIndex,
            itemChanged: (index) => itemChanged(
              read: ref.read,
              index: index,
              router: router,
            ),
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
              item(
                image: Assets.images.wallet,
                label: LocaleKeys.wallet.tr(),
              ),
              item(
                image: Assets.images.browser,
                label: LocaleKeys.browser.tr(),
              ),
              item(
                image: Assets.images.profile,
                label: LocaleKeys.profile.tr(),
              ),
            ],
          ),
        ),
      );

  Future<void> itemChanged({
    required Reader read,
    required int index,
    required TabsRouter router,
  }) async {
    if (index == router.activeIndex) {
      switch (index) {
        case 0:
          router.navigate(const WalletRoute());
          break;
        case 1:
          router.navigate(const BrowserRoute());
          break;
        case 2:
          router.navigate(const ProfileRouterRoute());
          break;
      }
    } else {
      router.setActiveIndex(index);
    }
  }

  BottomNavigationBarItem item({
    required SvgGenImage image,
    required String label,
  }) =>
      BottomNavigationBarItem(
        icon: image.svg(
          width: 24,
          height: 24,
        ),
        activeIcon: image.svg(
          width: 24,
          height: 24,
          color: CrystalColor.fontHeaderDark,
        ),
        label: label,
      );

  // ignore: avoid_positional_boolean_parameters
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
