import 'package:beamer/beamer.dart';
import 'package:ever_wallet/application/application_injection.dart';
import 'package:ever_wallet/application/application_localization.dart';
import 'package:ever_wallet/application/application_router.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ApplicationInjection(
        child: ApplicationRouter(
          builder: (beamerDelegate) => ApplicationLocalization(
            builder: (locale) => Portal(
              child: MaterialApp.router(
                routeInformationParser: BeamerParser(),
                routerDelegate: beamerDelegate,
                backButtonDispatcher: BeamerBackButtonDispatcher(delegate: beamerDelegate),
                debugShowCheckedModeBanner: false,
                onGenerateTitle: (context) => AppLocalizations.of(context)!.application_title,
                locale: locale?.toLocale(),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: materialTheme(context),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: child!,
                ),
              ),
            ),
          ),
        ),
      );
}
