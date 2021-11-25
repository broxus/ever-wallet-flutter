import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../domain/blocs/key/key_import_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../../../design/widgets/action_button.dart';
import '../../../design/widgets/crystal_title.dart';
import '../../../design/widgets/custom_app_bar.dart';
import '../../../design/widgets/custom_elevated_button.dart';
import '../../../design/widgets/custom_type_ahead_field.dart';
import '../../../design/widgets/text_field_index_icon.dart';
import '../../../design/widgets/text_suffix_icon_button.dart';
import '../../../design/widgets/unfocusing_gesture_detector.dart';
import '../../router.gr.dart';

enum _ButtonState {
  clear,
  paste,
}

class SeedPhraseImportPage extends StatefulWidget {
  final String? seedName;
  final bool isLegacy;

  const SeedPhraseImportPage({
    Key? key,
    this.seedName,
    required this.isLegacy,
  }) : super(key: key);

  @override
  State<SeedPhraseImportPage> createState() => _SeedPhraseImportPageState();
}

class _SeedPhraseImportPageState extends State<SeedPhraseImportPage> {
  final scrollController = ScrollController();
  final formKey = GlobalKey<FormState>();
  late final int wordsLength;
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;
  final formValidityNotifier = ValueNotifier<bool>(false);
  final buttonStateNotifier = ValueNotifier<_ButtonState>(_ButtonState.paste);
  final bloc = getIt.get<KeyImportBloc>();

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
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<KeyImportBloc, KeyImportState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is KeyImportStateError) {
            showErrorDialog(state.exception.toString());
          }

          if (state is KeyImportStateSuccess) {
            final words = controllers.map((e) => e.text).toList();

            context.router.push(
              PasswordCreationRoute(
                phrase: words,
                seedName: widget.seedName,
              ),
            );
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: UnfocusingGestureDetector(
            child: Scaffold(
              appBar: CustomAppBar(
                action: action(),
              ),
              body: body(),
            ),
          ),
        ),
      );

  void showErrorDialog(String text) => showPlatformDialog(
        context: context,
        builder: (context) => Theme(
          data: ThemeData(),
          child: PlatformAlertDialog(
            title: const Text('Error'),
            content: Text(text),
            actions: <Widget>[
              PlatformDialogAction(
                onPressed: () => context.router.navigatorKey.currentState?.pop(),
                child: const Text('Ok'),
              ),
            ],
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
        onPressed: () async {
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
            showErrorCrystalFlushbar(
              context,
              message: 'Incorrect words format',
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
        },
        text: LocaleKeys.actions_paste.tr(),
      );

  Widget clearButton() => ActionButton(
        key: const ValueKey(_ButtonState.clear),
        onPressed: () {
          for (final controller in controllers) {
            controller.text = '';
          }

          formValidityNotifier.value = false;
          buttonStateNotifier.value = _ButtonState.paste;
        },
        text: LocaleKeys.actions_clear.tr(),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
        text: LocaleKeys.seed_phrase_import_screen_title.tr(),
      );

  Widget list() {
    final half = wordsLength ~/ 2;

    return Form(
      key: formKey,
      onChanged: () => formValidityNotifier.value =
          (formKey.currentState?.validate() ?? false) && controllers.every((e) => e.text.isNotEmpty),
      child: Row(
        children: [
          Expanded(
            child: column(
              half: half,
            ),
          ),
          const SizedBox(width: 16),
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
            if (index != 0) const SizedBox(height: 16),
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
        hintText: 'Word...',
        prefixIcon: TextFieldIndexIcon(
          index: index,
        ),
        suffixIcon: SuffixIconButton(
          onPressed: () {
            controllers[index].clear();
            Form.of(context)?.validate();
          },
          icon: Assets.images.iconCross.svg(),
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
        suggestionsCallback: (pattern) => suggestionsCallback(
          pattern: pattern,
          index: index,
        ),
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
      return LocaleKeys.seed_phrase_check_screen_validation_errors_incorrect_word.tr();
    }
  }

  void onChanged(String value) {
    if (controllers.any((e) => e.text == 'speakfriendandenter')) {
      final key = generateKey(widget.isLegacy ? const MnemonicType.legacy() : const MnemonicType.labs(id: 0));

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
          onPressed: value
              ? () {
                  final words = controllers.map((e) => e.text).toList();

                  bloc.add(KeyImportEvent.import(words));
                }
              : null,
          text: LocaleKeys.actions_confirm.tr(),
        ),
      );
}