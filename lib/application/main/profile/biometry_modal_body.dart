import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/general/field/switch_field.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class BiometryModalBody extends StatefulWidget {
  const BiometryModalBody({super.key});

  @override
  _BiometryModalBodyState createState() => _BiometryModalBodyState();
}

class _BiometryModalBodyState extends State<BiometryModalBody> {
  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(20),
            getBiometricSwitcher(),
            const Gap(34),
          ],
        ),
      );

  Widget getBiometricSwitcher() {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return Row(
      children: [
        Expanded(
          child: Text(
            localization.enable_biometry,
            style: themeStyle.styles.basicStyle.copyWith(color: ColorsRes.text),
          ),
        ),
        const Gap(16),
        AsyncValueStreamProvider<bool>(
          create: (context) => context.read<BiometryRepository>().statusStream,
          builder: (context, child) {
            final isEnabled = context.watch<AsyncValue<bool>>().maybeWhen(
                  ready: (value) => value,
                  orElse: () => false,
                );

            return EWSwitchField(
              value: isEnabled,
              onChanged: (value) => context.read<BiometryRepository>().setStatus(
                    localizedReason: AppLocalizations.of(context)!.authentication_reason,
                    isEnabled: !isEnabled,
                  ),
            );
          },
        ),
      ],
    );
  }
}
