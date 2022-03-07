import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/biometry_repository.dart';
import '../../../../injection.dart';
import '../../../../providers/biometry/biometry_status_provider.dart';
import '../../../design/design.dart';

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
            const SizedBox(height: 20),
            getBiometricSwitcher(),
            const SizedBox(height: 34),
          ],
        ),
      );

  Widget getBiometricSwitcher() => Row(
        children: [
          Expanded(
            child: Text(
              LocaleKeys.biometry_checkbox.tr(),
              style: const TextStyle(
                color: CrystalColor.fontDark,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Consumer(
            builder: (context, ref, child) {
              final isEnabled = ref.watch(biometryStatusProvider).asData?.value ?? false;

              return PlatformSwitch(
                value: isEnabled,
                onChanged: (p0) => getIt.get<BiometryRepository>().setBiometryStatus(
                      localizedReason: 'Please authenticate to interact with wallet',
                      isEnabled: !isEnabled,
                    ),
              );
            },
          ),
        ],
      );
}
