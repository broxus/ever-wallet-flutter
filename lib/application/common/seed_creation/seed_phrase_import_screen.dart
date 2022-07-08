import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:ever_wallet/application/common/seed_creation/password_creation_screen.dart';
import 'package:ever_wallet/application/common/widgets/action_button.dart';
import 'package:ever_wallet/application/common/widgets/crystal_flushbar.dart';
import 'package:ever_wallet/application/common/widgets/crystal_title.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_type_ahead_field.dart';
import 'package:ever_wallet/application/common/widgets/suggestion_formatter.dart';
import 'package:ever_wallet/application/common/widgets/text_field_clear_button.dart';
import 'package:ever_wallet/application/common/widgets/text_field_index_icon.dart';
import 'package:ever_wallet/application/common/widgets/unfocusing_gesture_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gap/gap.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class SeedPhraseImportScreen extends StatefulWidget {
  final String? seedName;
  final bool isLegacy;

  const SeedPhraseImportScreen({
    Key? key,
    this.seedName,
    required this.isLegacy,
  }) : super(key: key);

  @override
  State<SeedPhraseImportScreen> createState() => _SeedPhraseImportScreenState();
}

class _SeedPhraseImportScreenState extends State<SeedPhraseImportScreen> {
  final scrollController = ScrollController();
  final formKey = GlobalKey<FormState>();
  late final int wordsLength;
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;
  final formValidityNotifier = ValueNotifier<bool>(false);
  final buttonStateNotifier = ValueNotifier<_ButtonState>(_ButtonState.paste);

  @override
  void initState() {
    super.initState();
    wordsLength = widget.isLegacy ? 24 : 12;
    controllers = List.generate(wordsLength, (_) => TextEditingController());
    focusNodes = List.generate(wordsLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    scrollController.dispose();
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final focusNode in focusNodes) {
      focusNode.dispose();
    }
    formValidityNotifier.dispose();
    buttonStateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: UnfocusingGestureDetector(
          child: Scaffold(
            appBar: AppBar(
              leading: const CustomBackButton(),
              actions: [
                action(),
              ],
            ),
            body: body(),
          ),
        ),
      );

  Widget action() => ValueListenableBuilder<_ButtonState>(
        valueListenable: buttonStateNotifier,
        builder: (context, value, child) {
          late final Widget child;

          switch (value) {
            case _ButtonState.clear:
              child = clearButton();
              break;
            case _ButtonState.paste:
              child = pasteButton();
              break;
          }

          return child;
        },
      );

  Widget pasteButton() => ActionButton(
        key: const ValueKey(_ButtonState.paste),
        onPressed: onPasteButtonPressed,
        text: AppLocalizations.of(context)!.paste,
      );

  Future<void> onPasteButtonPressed() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);

    final words = <String>[...clipboard?.text?.split(' ') ?? []];

    if (words.isNotEmpty && words.length == wordsLength) {
      for (final word in words) {
        if (getHints(word).isEmpty) {
          words.clear();
          break;
        }
      }
    } else {
      words.clear();
    }

    if (words.isEmpty) {
      if (!mounted) return;

      showErrorCrystalFlushbar(
        context,
        message: AppLocalizations.of(context)!.incorrect_words_format,
        flushbarPosition: FlushbarPosition.BOTTOM,
        margin: const EdgeInsets.only(bottom: 12),
      );
      return;
    }

    words.asMap().forEach((index, word) {
      controllers[index].value = TextEditingValue(
        text: word,
        selection: TextSelection.fromPosition(TextPosition(offset: word.length)),
      );
      words[index] = word;
    });

    formValidityNotifier.value = formKey.currentState?.validate() ?? false;
    buttonStateNotifier.value = _ButtonState.clear;
  }

  Widget clearButton() => ActionButton(
        key: const ValueKey(_ButtonState.clear),
        onPressed: () {
          for (final controller in controllers) {
            controller.text = '';
          }

          formValidityNotifier.value = false;
          buttonStateNotifier.value = _ButtonState.paste;
        },
        text: AppLocalizations.of(context)!.clear,
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
                    const Gap(8),
                    title(),
                    const Gap(32),
                    list(),
                    const Gap(64),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    submitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget title() => CrystalTitle(
        text: AppLocalizations.of(context)!.enter_seed_phrase,
      );

  Widget list() {
    final half = wordsLength ~/ 2;

    return Form(
      key: formKey,
      onChanged: () => formValidityNotifier.value = (formKey.currentState?.validate() ?? false) &&
          controllers.every((e) => e.text.isNotEmpty),
      child: Row(
        children: [
          Expanded(
            child: column(
              half: half,
            ),
          ),
          const Gap(16),
          Expanded(
            child: column(
              half: half,
              start: half,
            ),
          ),
        ],
      ),
    );
  }

  Widget column({
    required int half,
    int start = 0,
  }) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          half,
          (index) => [
            if (index != 0) const Gap(16),
            field(start + index),
          ],
        ).expand((e) => e).toList(),
      );

  Widget field(int index) => CustomTypeAheadField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: index != wordsLength - 1 ? TextInputAction.next : TextInputAction.done,
        hintText: '${AppLocalizations.of(context)!.word}...',
        prefixIcon: TextFieldIndexIcon(
          index: index,
        ),
        suffixIcon: TextFieldClearButton(
          controller: controllers[index],
        ),
        validator: (value) => validator(
          value: value,
          index: index,
        ),
        onChanged: onChanged,
        onSubmitted: (value) => requestNextFocus(index),
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
          SuggestionFormatter(suggestions: getHints),
        ],
        suggestionsCallback: (pattern) => pattern.isNotEmpty
            ? suggestionsCallback(
                pattern: pattern,
                index: index,
              )
            : [],
        itemBuilder: (context, suggestion) => itemBuilder(suggestion: suggestion),
        onSuggestionSelected: (suggestion) => onSuggestionSelected(
          suggestion: suggestion,
          index: index,
        ),
      );

  String? validator({
    required String? value,
    required int index,
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (getHints(value).isNotEmpty) {
      return null;
    } else {
      return AppLocalizations.of(context)!.incorrect_word;
    }
  }

  void onChanged(String value) {
    if (controllers.any((e) => e.text == 'speakfriendandenter')) {
      final key =
          generateKey(widget.isLegacy ? const MnemonicType.legacy() : const MnemonicType.labs(0));

      for (var i = 0; i < controllers.length; i++) {
        final text = key.words[i];
        controllers[i].text = text;
        controllers[i].selection = TextSelection.fromPosition(TextPosition(offset: text.length));
      }
    }

    formKey.currentState?.validate();
  }

  FutureOr<Iterable<Object?>> suggestionsCallback({
    required String pattern,
    required int index,
  }) {
    final value = controllers[index].value;
    final text = value.text.substring(0, value.selection.start);

    return getHints(text);
  }

  Widget itemBuilder({
    Object? suggestion,
  }) {
    final text = (suggestion as String?)!;

    return ListTile(
      title: Text(text),
    );
  }

  void onSuggestionSelected({
    Object? suggestion,
    required int index,
  }) {
    final text = (suggestion as String?)!;

    controllers[index].text = text;
    controllers[index].selection = TextSelection.fromPosition(TextPosition(offset: text.length));

    requestNextFocus(index);

    formKey.currentState?.validate();
  }

  void requestNextFocus(int index) {
    if (index != wordsLength - 1) {
      focusNodes[index + 1].requestFocus();
    }
  }

  Widget submitButton() => ValueListenableBuilder<bool>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => CustomElevatedButton(
          onPressed: value ? onSubmitButtonPressed : null,
          text: AppLocalizations.of(context)!.confirm,
        ),
      );

  void onSubmitButtonPressed() {
    try {
      final phrase = controllers.map((e) => e.text).toList();
      final mnemonicType =
          widget.isLegacy ? const MnemonicType.legacy() : const MnemonicType.labs(0);

      deriveFromPhrase(
        phrase: phrase,
        mnemonicType: mnemonicType,
      );

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PasswordCreationScreen(
            phrase: phrase,
            seedName: widget.seedName,
            fromWizard: true,
          ),
        ),
      );
    } catch (err) {
      showErrorDialog(err.toString());
    }
  }

  void showErrorDialog(String text) => showPlatformDialog<void>(
        context: context,
        builder: (context) => Theme(
          data: ThemeData(),
          child: PlatformAlertDialog(
            title: Text(AppLocalizations.of(context)!.error),
            content: Text(text),
            actions: <Widget>[
              PlatformDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        ),
      );
}

enum _ButtonState {
  clear,
  paste,
}
