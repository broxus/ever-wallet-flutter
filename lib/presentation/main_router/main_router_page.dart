import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
