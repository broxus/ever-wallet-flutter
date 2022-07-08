import 'package:ever_wallet/application/bloc/common/locale_cubit.dart';
import 'package:ever_wallet/application/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

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
            const Gap(20),
            availableLanguages(),
            const Gap(34),
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
        title: Text(locale.languageCode.toLocaleName()),
        onTap: () {
          context.read<LocaleCubit>().setLocale(locale.toStringWithSeparator());
          Navigator.of(context).pop();
        },
        trailing: SizedBox.square(
          dimension: 48,
          child: SvgPicture.asset(
            'icons/flags/svg/${locale.languageCode.toLocaleIcon()}.svg',
            package: 'country_icons',
          ),
        ),
      );
}
