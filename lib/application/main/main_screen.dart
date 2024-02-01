import 'dart:async';

import 'package:ever_wallet/application/main/browser/browser_page.dart';
import 'package:ever_wallet/application/main/profile/profile_page.dart';
import 'package:ever_wallet/application/main/wallet/wallet_screen.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/repositories/browser_navigation_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreenRoute extends MaterialPageRoute<void> {
  MainScreenRoute()
      : super(
          builder: (context) => MainScreen(key: context.read<GlobalKey<MainScreenState>>()),
        );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late final StreamSubscription<BrowserNavigation> navigationSubscription;

  final controller = CupertinoTabController();

  final keysList = List<GlobalKey<NavigatorState>>.generate(3, (_) => GlobalKey());

  final pages = <Widget>[
    const WalletScreen(),
    const BrowserPage(),
    const ProfilePage(),
  ];

  bool tryPop() {
    final current = keysList[controller.index].currentState;
    if (current != null && current.canPop()) {
      current.maybePop();
      return false;
    }
    if (controller.index != 0) {
      controller.index = 0;
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    navigationSubscription = context
        .read<BrowserNavigationRepository>()
        .navigationStream
        .listen(_onBrowserNavigation);
  }

  @override
  Future<void> dispose() async {
    await navigationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => tryPop(),
        child: CupertinoTabScaffold(
          controller: controller,
          resizeToAvoidBottomInset: false,
          tabBuilder: (BuildContext context, int index) {
            return CupertinoTabView(
              navigatorKey: keysList[index],
              builder: (_) => pages[index],
            );
          },
          tabBar: CupertinoTabBar(
            activeColor: ColorsRes.bluePrimary400,
            // Do not set opacity to background, it removes bottom padding
            backgroundColor: ColorsRes.greyOpacity.withOpacity(1),
            inactiveColor: ColorsRes.neutral500,
            items: [
              item(
                image: Assets.images.wallet,
                label: context.localization.wallet,
              ),
              item(
                image: Assets.images.browserSvg,
                label: context.localization.browser,
              ),
              item(
                image: Assets.images.profile,
                label: context.localization.profile,
              ),
            ],
          ),
        ),
      );

  BottomNavigationBarItem item({
    required SvgGenImage image,
    required String label,
  }) =>
      BottomNavigationBarItem(
        icon: image.svg(
          width: 24,
          height: 24,
          color: ColorsRes.neutral500,
        ),
        activeIcon: image.svg(
          width: 24,
          height: 24,
          color: ColorsRes.bluePrimary400,
        ),
        label: label,
      );

  void _onBrowserNavigation(BrowserNavigation value) {
    controller.index = 1;
  }
}
