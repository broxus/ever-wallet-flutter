import 'package:flutter/material.dart';

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
        child: MaterialApp.router(
          title: applicationTitle,
          theme: applicationTheme,
          debugShowCheckedModeBanner: false,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          localizationsDelegates: context.localizationDelegates,
          routerDelegate: appRouter.delegate(),
          routeInformationParser: appRouter.defaultRouteParser(),
        ),
      );
}
