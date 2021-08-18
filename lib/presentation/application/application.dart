import 'package:flutter/material.dart';

import '../../router.gr.dart';
import '../design/design.dart';
import 'application_listener.dart';
import 'application_localization.dart';
import 'application_provider.dart';

class Application extends StatefulWidget {
  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) => ApplicationLocalization(
        child: ApplicationProvider(
          child: ApplicationListener(
            appRouter: _appRouter,
            builder: (BuildContext context) => buildMaterialApp(context),
          ),
        ),
      );

  MaterialApp buildMaterialApp(BuildContext context) => MaterialApp.router(
        title: LocaleKeys.application_title.tr(),
        theme: CrystalTheme.original,
        debugShowCheckedModeBanner: false,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        localizationsDelegates: context.localizationDelegates,
        routerDelegate: _appRouter.delegate(),
        routeInformationParser: _appRouter.defaultRouteParser(),
        builder: (context, child) => MediaQuery(
          data: context.media.copyWith(textScaleFactor: 1.0),
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowGlow();
              return true;
            },
            child: child ?? const SizedBox(),
          ),
        ),
      );
}
