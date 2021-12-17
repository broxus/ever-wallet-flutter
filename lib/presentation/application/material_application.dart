import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

import '../design/design.dart';
import '../routes/router.gr.dart';

class MaterialApplication extends StatelessWidget {
  final AppRouter appRouter;

  const MaterialApplication({
    Key? key,
    required this.appRouter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: CrystalColor.background,
        child: Portal(
          child: MaterialApp.router(
            title: applicationTitle,
            theme: applicationTheme(context),
            debugShowCheckedModeBanner: false,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            localizationsDelegates: context.localizationDelegates,
            routerDelegate: appRouter.delegate(),
            routeInformationParser: appRouter.defaultRouteParser(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child ?? const SizedBox(),
            ),
          ),
        ),
      );
}
