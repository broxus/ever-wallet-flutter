import 'package:flutter/material.dart';

import '../design/design.dart';
import '../router.gr.dart';
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
            builder: (BuildContext context) => buildApp(context),
          ),
        ),
      );

  Widget buildApp(BuildContext context) => Container(
        color: CrystalColor.background,
        child: MaterialApp.router(
          title: 'TON Crystal',
          theme: applicationTheme,
          debugShowCheckedModeBanner: false,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          localizationsDelegates: context.localizationDelegates,
          routerDelegate: _appRouter.delegate(),
          routeInformationParser: _appRouter.defaultRouteParser(),
        ),
      );
}
