import 'package:beamer/beamer.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/main/browser/browser_page.dart';
import 'package:ever_wallet/application/main/profile/profile_page.dart';
import 'package:ever_wallet/application/main/wallet/wallet_screen.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:ever_wallet/generated/fonts.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final routerDelegates = [
    BeamerDelegate(
      initialPath: '/main/wallet',
      locationBuilder: (routeInformation, _) {
        if (routeInformation.location!.contains('wallet')) {
          return WalletLocation(routeInformation);
        }
        return NotFound(path: routeInformation.location!);
      },
    ),
    BeamerDelegate(
      initialPath: '/main/browser',
      locationBuilder: (routeInformation, _) {
        if (routeInformation.location!.contains('browser')) {
          return BrowserLocation(routeInformation);
        }
        return NotFound(path: routeInformation.location!);
      },
    ),
    BeamerDelegate(
      initialPath: '/main/profile',
      locationBuilder: (routeInformation, _) {
        if (routeInformation.location!.contains('profile')) {
          return ProfileLocation(routeInformation);
        }
        return NotFound(path: routeInformation.location!);
      },
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uriString = Beamer.of(context).configuration.location!;
    switch (uriString) {
      case 'wallet':
        currentIndex = 0;
        break;
      case 'browser':
        currentIndex = 1;
        break;
      case 'profile':
        currentIndex = 2;
        break;
    }
  }

  @override
  Widget build(BuildContext context) => CupertinoTheme(
        data: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            tabLabelTextStyle: TextStyle(
              fontFamily: FontFamily.pt,
              fontSize: 11,
              letterSpacing: 0.2,
            ),
          ),
        ),
        child: Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: [
              Beamer(
                routerDelegate: routerDelegates[0],
              ),
              Beamer(
                routerDelegate: routerDelegates[1],
              ),
              Beamer(
                routerDelegate: routerDelegates[2],
              ),
            ],
          ),
          bottomNavigationBar: PlatformNavBar(
            currentIndex: currentIndex,
            items: [
              item(
                image: Assets.images.wallet,
                label: AppLocalizations.of(context)!.wallet,
              ),
              item(
                image: Assets.images.browser,
                label: AppLocalizations.of(context)!.browser,
              ),
              item(
                image: Assets.images.profile,
                label: AppLocalizations.of(context)!.profile,
              ),
            ],
            itemChanged: (index) {
              if (index != currentIndex) {
                setState(() => currentIndex = index);
                routerDelegates[currentIndex].update(rebuild: false);
              }
            },
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
        ),
        activeIcon: image.svg(
          width: 24,
          height: 24,
          color: CrystalColor.fontHeaderDark,
        ),
        label: label,
      );
}

class WalletLocation extends BeamLocation<BeamState> {
  WalletLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns => ['/main/wallet'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
          key: ValueKey('wallet'),
          title: 'Wallet',
          type: BeamPageType.noTransition,
          child: WalletScreen(),
        ),
      ];
}

class BrowserLocation extends BeamLocation<BeamState> {
  BrowserLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns => ['/main/browser'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
          key: ValueKey('browser'),
          title: 'Browser',
          type: BeamPageType.noTransition,
          child: BrowserPage(),
        ),
      ];
}

class ProfileLocation extends BeamLocation<BeamState> {
  ProfileLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns => ['/main/profile'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(
          key: ValueKey('profile'),
          title: 'Profile',
          type: BeamPageType.noTransition,
          child: ProfilePage(),
        ),
      ];
}
