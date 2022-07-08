import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class BiometryModalBody extends StatefulWidget {
  const BiometryModalBody({Key? key}) : super(key: key);

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

  Widget getBiometricSwitcher() => Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.enable_biometry,
              style: const TextStyle(
                color: CrystalColor.fontDark,
              ),
            ),
          ),
          const Gap(16),
          StreamProvider<AsyncValue<bool>>(
            create: (context) => context
                .read<BiometryRepository>()
                .statusStream
                .map((event) => AsyncValue.ready(event)),
            initialData: const AsyncValue.loading(),
            catchError: (context, error) => AsyncValue.error(error),
            builder: (context, child) {
              final isEnabled = context.watch<AsyncValue<bool>>().maybeWhen(
                    ready: (value) => value,
                    orElse: () => false,
                  );

              return PlatformSwitch(
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
