import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/biometry_repository.dart';
import '../injection.dart';
import '../providers/key/keys_presence_provider.dart';
import 'common/theme.dart';
import 'router.gr.dart';

class Application extends StatefulWidget {
  const Application({Key? key}) : super(key: key);

  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> with WidgetsBindingObserver {
  final appRouter = AppRouter();

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) getIt.get<BiometryRepository>().checkAvailability();
  }

  @override
  Widget build(BuildContext context) => EasyLocalization(
        path: 'assets/localizations',
        supportedLocales: const [
          Locale('en'),
        ],
        fallbackLocale: const Locale('en'),
        useOnlyLangCode: true,
        child: ProviderScope(
          child: Portal(
            child: ColoredBox(
              color: CrystalColor.background,
              child: Consumer(
                builder: (context, ref, child) {
                  ref.listen<AsyncValue<bool>>(
                    keysPresenceProvider,
                    (previous, next) {
                      next.whenData((value) {
                        if (value) {
                          appRouter.root.pushAndPopUntil(
                            const MainRouterRoute(),
                            predicate: (route) => false,
                          );
                        } else {
                          appRouter.root.pushAndPopUntil(
                            const WizardRouterRoute(),
                            predicate: (route) => false,
                          );
                        }
                      });
                    },
                  );

                  return MaterialApp.router(
                    title: applicationTitle,
                    theme: materialTheme(context),
                    debugShowCheckedModeBanner: false,
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,
                    localizationsDelegates: context.localizationDelegates,
                    routerDelegate: appRouter.delegate(),
                    routeInformationParser: appRouter.defaultRouteParser(),
                    builder: (context, child) => CupertinoTheme(
                      data: cupertinoTheme(context),
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                        child: child!,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
}
