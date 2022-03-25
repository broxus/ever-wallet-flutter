import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../widgets/crystal_title.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_elevated_button.dart';

class SeedPhraseTypePage extends StatelessWidget {
  final void Function(MnemonicType mnemonicType) onSelected;

  const SeedPhraseTypePage({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          appBar: AppBar(
            leading: const CustomBackButton(),
          ),
          body: body(),
        ),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16) - const EdgeInsets.only(top: 16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    title(),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    seedButton(
                      title: 'Regular seed',
                      subtitle: 'The seed phrase contains 12 words',
                      mnemonicType: const MnemonicType.labs(id: 0),
                    ),
                    const SizedBox(height: 16),
                    seedButton(
                      title: 'Legacy seed',
                      subtitle: 'The seed phrase contains 24 words',
                      mnemonicType: const MnemonicType.legacy(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget title() => const CrystalTitle(
        text: 'Please select the type of seed phrase',
      );

  Widget seedButton({
    required String title,
    required String subtitle,
    required MnemonicType mnemonicType,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            CustomElevatedButton(
              onPressed: () => onSelected(mnemonicType),
              text: 'Select',
            ),
          ],
        ),
      );
}
