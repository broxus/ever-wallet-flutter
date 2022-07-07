import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../injection.dart';
import '../../../../data/repositories/biometry_repository.dart';
import '../../../../injection.dart';
import '../../../../providers/biometry/biometry_status_provider.dart';
import '../../common/general/field/switch_field.dart';
import '../../util/colors.dart';
import '../../util/extensions/context_extensions.dart';

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
        const SizedBox(width: 16),
        Consumer(
          builder: (context, ref, child) {
            final isEnabled = ref.watch(biometryStatusProvider).asData?.value ?? false;

            return EWSwitchField(
              value: isEnabled,
              onChanged: (value) => getIt.get<BiometryRepository>().setStatus(
                    localizedReason: localization.authentication_reason,
                    isEnabled: !isEnabled,
                  ),
            );
          },
        ),
      ],
    );
  }
}
