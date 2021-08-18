import 'package:flutter/material.dart';

import '../design/design.dart';

class ApplicationLocalization extends StatelessWidget {
  final Widget child;

  const ApplicationLocalization({
    required this.child,
  });

  @override
  Widget build(BuildContext context) => EasyLocalization(
        path: "assets/localizations",
        supportedLocales: const [
          Locale("en"),
        ],
        fallbackLocale: const Locale("en"),
        useOnlyLangCode: true,
        child: child,
      );
}
