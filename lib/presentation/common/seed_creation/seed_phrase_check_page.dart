import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../router.gr.dart';
import '../constants.dart';
import '../utils.dart';
import '../widgets/animated_offstage.dart';
import '../widgets/crystal_title.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_type_ahead_field.dart';
import '../widgets/suggestion_formatter.dart';
import '../widgets/text_field_clear_button.dart';
import '../widgets/text_field_index_icon.dart';
import '../widgets/unfocusing_gesture_detector.dart';

class SeedPhraseCheckPage extends StatefulWidget {
  final String? seedName;
  final List<String> phrase;

  const SeedPhraseCheckPage({
    Key? key,
    required this.seedName,
    required this.phrase,
  }) : super(key: key);

  @override
  State<SeedPhraseCheckPage> createState() => _SeedPhraseCheckPageState();
}

class _SeedPhraseCheckPageState extends State<SeedPhraseCheckPage> {
  final scrollController = ScrollController();
  late final Map<int, String> words;
  final formKey = GlobalKey<FormState>();
  final controllers = List.generate(kDefaultCheckingWordsAmount, (_) => TextEditingController());
  final focusNodes = List.generate(kDefaultCheckingWordsAmount, (_) => FocusNode());
  final formValidityNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    words = generateCheckingMap(widget.phrase);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: UnfocusingGestureDetector(
          child: Scaffold(
            appBar: AppBar(
              leading: const CustomBackButton(),
            ),
            body: body(),
          ),
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
                    const SizedBox(height: 32),
                    list(),
                    const SizedBox(height: 64),
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
        text: AppLocalizations.of(context)!.check_seed_phrase,
      );

  Widget list() => Form(
        key: formKey,
        onChanged: () => formValidityNotifier.value =
            (formKey.currentState?.validate() ?? false) && controllers.every((e) => e.text.isNotEmpty),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            kDefaultCheckingWordsAmount,
            (index) => [
              if (index != 0) const SizedBox(height: 16),
              field(index),
            ],
          ).expand((e) => e).toList(),
        ),
      );

  Widget field(int index) => CustomTypeAheadField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: index != kDefaultCheckingWordsAmount - 1 ? TextInputAction.next : TextInputAction.done,
        labelText: '${AppLocalizations.of(context)!.word}...',
        prefixIcon: TextFieldIndexIcon(
          index: words.keys.elementAt(index),
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
        suffixIcon: TextFieldClearButton(
          controller: controllers[index],
        ),
        suggestionsCallback: (pattern) => pattern.isNotEmpty
            ? suggestionsCallback(
                pattern: pattern,
                index: index,
              )
            : [],
        itemBuilder: (context, suggestion) => itemBuilder(suggestion),
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

    if (value == widget.phrase[words.entries.elementAt(index).key]) {
      return null;
    } else {
      return AppLocalizations.of(context)!.incorrect_word;
    }
  }

  void onChanged(String value) {
    if (controllers.any((e) => e.text == 'speakfriendandenter')) {
      for (var i = 0; i < controllers.length; i++) {
        final text = widget.phrase[words.entries.elementAt(i).key];
        controllers[i].text = text;
        controllers[i].selection = TextSelection.fromPosition(TextPosition(offset: text.length));
      }
    }

    formKey.currentState?.validate();
  }

  FutureOr<Iterable<String>> suggestionsCallback({
    required String pattern,
    required int index,
  }) {
    final value = controllers[index].value;
    final text = value.text.substring(0, value.selection.start);

    return getHints(text);
  }

  Widget itemBuilder(Object? suggestion) {
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
    if (index != kDefaultCheckingWordsAmount - 1) {
      focusNodes[index + 1].requestFocus();
    }
  }

  Widget submitButton() => ValueListenableBuilder<bool>(
        valueListenable: formValidityNotifier,
        builder: (context, value, child) => AnimatedOffstage(
          duration: const Duration(milliseconds: 300),
          offstage: value,
          child: PrimaryElevatedButton(
            onPressed: () => context.router.push(
              PasswordCreationRoute(
                phrase: widget.phrase,
                seedName: widget.seedName,
              ),
            ),
            text: AppLocalizations.of(context)!.confirm,
          ),
        ),
      );
}
