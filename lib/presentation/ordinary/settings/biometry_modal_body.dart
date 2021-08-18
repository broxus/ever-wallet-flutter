import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../design/design.dart';

class BiometryModalBody extends StatefulWidget {
  const BiometryModalBody({Key? key}) : super(key: key);

  @override
  _BiometryModalBodyState createState() => _BiometryModalBodyState();
}

class _BiometryModalBodyState extends State<BiometryModalBody> {
  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CrystalDivider(height: 20),
            getBiometricSwitcher(),
            const CrystalDivider(height: 34),
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
          const CrystalDivider(width: 16.0),
          BlocBuilder<BiometryInfoBloc, BiometryInfoState>(
            bloc: context.watch<BiometryInfoBloc>(),
            builder: (context, state) => CrystalSwitch(
              isActive: state.isEnabled,
              onTap: () => context
                  .read<BiometryInfoBloc>()
                  .add(BiometryInfoEvent.setBiometryStatus(isEnabled: !state.isEnabled)),
            ),
          ),
        ],
      );
}
