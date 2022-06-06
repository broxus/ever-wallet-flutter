import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';

import '../../application.dart';
import '../../bloc/locale_cubit.dart';

class LanguageModalBody extends StatefulWidget {
  const LanguageModalBody({Key? key}) : super(key: key);

  @override
  _LanguageModalBodyState createState() => _LanguageModalBodyState();
}

class _LanguageModalBodyState extends State<LanguageModalBody> {
  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            availableLanguages(),
            const SizedBox(height: 34),
          ],
        ),
      );

  Widget availableLanguages() => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => item(AppLocalizations.supportedLocales[index]),
        itemCount: AppLocalizations.supportedLocales.length,
        shrinkWrap: true,
      );

  Widget item(Locale locale) => ListTile(
        title: Text(list[locale.languageCode]!.name),
        onTap: () => context.read<LocaleCubit>().setLocale(locale),
        trailing: SizedBox.square(
          dimension: 48,
          child: SvgPicture.asset('icons/flags/svg/${list[locale.languageCode]!.icon}.svg', package: 'country_icons'),
        ),
      );
}
