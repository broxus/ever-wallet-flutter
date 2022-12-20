import 'dart:async';

import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/dialog/default_dialog_controller.dart';
import 'package:ever_wallet/application/common/general/field/bordered_input.dart';
import 'package:ever_wallet/application/common/general/field/switch_field.dart';
import 'package:ever_wallet/application/common/general/onboarding_appbar.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const kPasswordInputHeight = 52.0;

typedef CreatePasswordWidgetNavigationCallback = void Function(BuildContext context);

class CreateSeedPasswordWidget extends StatefulWidget {
  const CreateSeedPasswordWidget({
    required this.phrase,
    required this.name,
    required this.callback,
    required this.setCurrentKey,
    required this.primaryColor,
    required this.defaultTextColor,
    required this.secondaryTextColor,
    required this.buttonTextColor,
    required this.errorColor,
    required this.needBiometryIfPossible,
    super.key,
  });

  final List<String> phrase;
  final String? name;
  final CreatePasswordWidgetNavigationCallback callback;
  final bool setCurrentKey;

  final Color primaryColor;
  final Color defaultTextColor;
  final Color secondaryTextColor;
  final Color buttonTextColor;
  final Color errorColor;
  final bool needBiometryIfPossible;

  @override
  State<CreateSeedPasswordWidget> createState() => _CreateSeedPasswordWidgetState();
}

class _CreateSeedPasswordWidgetState extends State<CreateSeedPasswordWidget> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final passwordFocus = FocusNode();
  final confirmFocus = FocusNode();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.themeStyle;
    final localization = context.localization;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: OnboardingAppBar(backColor: widget.primaryColor),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.create_password,
                  style: StylesRes.sheetHeaderTextFaktum.copyWith(color: widget.defaultTextColor),
                ),
                const SizedBox(height: 16),
                Text(
                  localization.create_password_description,
                  style: themeStyle.styles.basicStyle.copyWith(color: widget.secondaryTextColor),
                ),
                const SizedBox(height: 32),
                BorderedInput(
                  obscureText: true,
                  height: kPasswordInputHeight,
                  controller: passwordController,
                  textStyle: StylesRes.basicText.copyWith(color: widget.defaultTextColor),
                  focusNode: passwordFocus,
                  label: localization.your_password,
                  cursorColor: widget.defaultTextColor,
                  activeBorderColor: widget.primaryColor,
                  inactiveBorderColor: widget.secondaryTextColor,
                  onSubmitted: (_) => confirmFocus.requestFocus(),
                  validator: (_) {
                    if (passwordController.text.length >= 8) {
                      return null;
                    }
                    return localization.password_length;
                  },
                ),
                const SizedBox(height: 12),
                BorderedInput(
                  obscureText: true,
                  height: kPasswordInputHeight,
                  controller: confirmController,
                  focusNode: confirmFocus,
                  label: localization.confirm_password,
                  textStyle: StylesRes.basicText.copyWith(color: widget.defaultTextColor),
                  textInputAction: TextInputAction.done,
                  cursorColor: widget.defaultTextColor,
                  activeBorderColor: widget.primaryColor,
                  inactiveBorderColor: widget.secondaryTextColor,
                  onSubmitted: (_) => _nextAction(),
                  validator: (_) {
                    if (confirmController.text == passwordController.text) {
                      return null;
                    }

                    return localization.passwords_match;
                  },
                ),
                const SizedBox(height: 12),
                if (widget.needBiometryIfPossible) getBiometricSwitcher(),
                const Spacer(),
                PrimaryButton(
                  text: localization.next,
                  backgroundColor: widget.primaryColor,
                  style: StylesRes.buttonText.copyWith(color: widget.buttonTextColor),
                  onPressed: () => _nextAction(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getBiometricSwitcher() {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return StreamProvider<AsyncValue<bool>>(
      create: (context) => context
          .read<BiometryRepository>()
          .availabilityStream
          .map((event) => AsyncValue.ready(event)),
      initialData: const AsyncValue.loading(),
      catchError: (context, error) => AsyncValue.error(error),
      builder: (context, child) {
        final isAvailable = context.watch<AsyncValue<bool>>().maybeWhen(
              ready: (value) => value,
              orElse: () => false,
            );

        return !isAvailable
            ? const SizedBox()
            : Container(
                color: ColorsRes.lightBlue.withOpacity(0.1),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localization.use_biometry_for_fast_login,
                        style: themeStyle.styles.basicStyle,
                      ),
                    ),
                    const SizedBox(width: 16),
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

                        return EWSwitchField(
                          value: isEnabled,
                          onChanged: (value) => context.read<BiometryRepository>().setStatus(
                                localizedReason: context.localization.authentication_reason,
                                isEnabled: !isEnabled,
                              ),
                        );
                      },
                    ),
                  ],
                ),
              );
      },
    );
  }

  Future<void> _nextAction() async {
    if (formKey.currentState?.validate() ?? false) {
      final keyRepo = context.read<KeysRepository>();
      final accountsRepo = context.read<AccountsRepository>();
      final key = await keyRepo.createKey(
        phrase: widget.phrase,
        password: passwordController.text,
        name: widget.name,
      );
      // make key visible for subscribers
      if (widget.setCurrentKey) await keyRepo.setCurrentKey(key.publicKey);

      final overlay = DefaultDialogController.showFullScreenLoader();

      /// wait until all streams complete sending data
      await Future<void>.delayed(const Duration(milliseconds: 100));

      /// Waits for founding any accounts. If no accounts found - start creating a new one
      late StreamSubscription sub;
      sub = accountsRepo.accountsStream
          .where((event) => event.isNotEmpty)
          .timeout(const Duration(seconds: 1), onTimeout: (c) => c.close())
          .listen(
        (accounts) {
          overlay.dismiss(animate: false);
          widget.callback(context);
          sub.cancel();
        },
        onDone: () async {
          if (widget.setCurrentKey) {
            await context.read<AccountsRepository>().addAccount(
                  publicKey: key.publicKey,
                  walletType: kDefaultWalletType,
                  workchain: kDefaultWorkchain,
                );
          }
          overlay.dismiss(animate: false);
          if (mounted) {
            widget.callback(context);
          }
          sub.cancel();
        },
      );
    }
  }
}
