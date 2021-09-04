import 'dart:math' as math;

import 'package:another_flushbar/flushbar.dart';
import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../domain/blocs/key/phrase_import_bloc.dart';
import '../../injection.dart';
import '../design/design.dart';
import '../design/utils.dart';
import '../design/widget/crystal_scaffold.dart';
import '../router.gr.dart';

enum _ButtonState {
  clear,
  paste,
}

class SeedPhraseImportPage extends StatefulWidget {
  final String? seedName;
  final bool isLegacy;

  const SeedPhraseImportPage({
    this.seedName,
    required this.isLegacy,
  });

  @override
  _SeedPhraseImportPageState createState() => _SeedPhraseImportPageState();
}

class _SeedPhraseImportPageState extends State<SeedPhraseImportPage> {
  final scrollController = ScrollController();
  final formKey = GlobalKey<FormState>();
  final bloc = getIt.get<PhraseImportBloc>();
  late final List<String> words;
  late final List<FocusNode> focuses;
  late final List<TextEditingController> controllers;
  late final int wordsCount;
  final buttonState = ValueNotifier<_ButtonState>(_ButtonState.paste);
  final isFormValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    wordsCount = widget.isLegacy ? 24 : 12;
    words = List<String>.generate(wordsCount, (_) => '');
    focuses = List.generate(wordsCount, (_) => FocusNode());
    controllers = List.generate(wordsCount, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (int i = 0; i < wordsCount; i++) {
      focuses[i].dispose();
      controllers[i].dispose();
    }
    scrollController.dispose();
    buttonState.dispose();
    bloc.close();
    isFormValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<PhraseImportBloc, PhraseImportState>(
        bloc: bloc,
        listener: (context, state) => state.when(
          initial: () => null,
          success: (phrase) => context.router.push(
            PasswordCreationRoute(
              phrase: words,
              seedName: widget.seedName,
            ),
          ),
          error: (info) => showPlatformDialog(
            context: context,
            builder: (context) => PlatformAlertDialog(
              title: const Text('Error'),
              content: Text(info),
              actions: <Widget>[
                PlatformDialogAction(
                  onPressed: () => context.router.navigatorKey.currentState?.pop(),
                  child: const Text('Ok'),
                ),
              ],
            ),
          ),
        ),
        child: CrystalScaffold(
          actions: ValueListenableBuilder<_ButtonState>(
            valueListenable: buttonState,
            builder: (context, value, child) {
              late final Widget child;

              switch (value) {
                case _ButtonState.clear:
                  child = buildClearButton();
                  break;
                case _ButtonState.paste:
                  child = buildPasteButton();
                  break;
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: child,
              );
            },
          ),
          onScaffoldTap: FocusScope.of(context).unfocus,
          headlineSize: 28,
          headline: LocaleKeys.seed_phrase_import_screen_title.tr(),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                SizedBox.expand(child: buildFieldLayout()),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: buildActions(),
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildPasteButton() => ExpandTapWidget(
        key: const ValueKey('paste_button'),
        onTap: () async {
          final wordsFromClipboard = await getWordsFromClipboard();

          if (wordsFromClipboard == null) {
            showErrorCrystalFlushbar(
              context,
              message: 'Incorrect words format',
              flushbarPosition: FlushbarPosition.BOTTOM,
              margin: const EdgeInsets.only(bottom: 12),
            );
            return;
          }

          wordsFromClipboard.asMap().forEach((index, word) {
            controllers[index].value = TextEditingValue(
              text: word,
              selection: TextSelection.collapsed(offset: word.length),
            );
            words[index] = word;
          });
          isFormValid.value = formKey.currentState?.validate() ?? false;

          buttonState.value = _ButtonState.clear;
        },
        tapPadding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.only(right: 16, top: 12),
          child: SizedBox(
            height: 24,
            child: Center(
              child: Text(
                LocaleKeys.actions_paste.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  color: CrystalColor.accent,
                  letterSpacing: 0.75,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      );

  Widget buildClearButton() => ExpandTapWidget(
        key: const ValueKey('clear_button'),
        onTap: () {
          for (final controller in controllers) {
            controller.text = '';
          }

          for (var index = 0; index < words.length; index++) {
            words[index] = '';
          }

          isFormValid.value = false;

          buttonState.value = _ButtonState.paste;
        },
        tapPadding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.only(right: 16, top: 12),
          child: SizedBox(
            height: 24,
            child: Center(
              child: Text(
                LocaleKeys.actions_clear.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  color: CrystalColor.accent,
                  letterSpacing: 0.75,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      );

  Widget buildFieldLayout() {
    final bottomKeyboardPadding = math.max(
      getKeyboardInsetsBottom(context),
      0,
    );

    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          top: 20,
          bottom: bottomKeyboardPadding + CrystalButton.kHeight + 24,
        ),
        child: Form(
          key: formKey,
          child: buildInputGrid(
            columns: MediaQuery.of(context).size.shortestSide >= 375 ? 2 : 1,
            fieldBuilder: (index) => CrystalTextFormField(
              maxLength: 24,
              enableInteractiveSelection: false,
              focusNode: focuses[index],
              controller: controllers[index],
              autocorrect: false,
              onEditingComplete: requestNextFocus,
              onFieldSubmitted: (_) => requestNextFocus(),
              scrollPadding: EdgeInsets.only(
                top: 32,
                bottom: bottomKeyboardPadding + CrystalButton.kHeight + 24,
              ),
              prefix: Center(
                child: Text(
                  "${index + 1}.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.25,
                    color: CrystalColor.fontDark,
                  ),
                ),
              ),
              hintText: LocaleKeys.seed_phrase_import_screen_hint.tr(),
              prefixConstraints: const BoxConstraints(
                maxWidth: 38,
                minWidth: 38,
              ),
              onChanged: (s) {
                words[index] = validateWord(s) ?? '';

                isFormValid.value = controllers.every((e) => e.text.isNotEmpty);

                if (controllers[index].text.isNotEmpty) {
                  buttonState.value = _ButtonState.clear;
                }
              },
              validator: (value) => validateWord(value) == null
                  ? LocaleKeys.seed_phrase_import_screen_validation_errors_incorrect_word.tr()
                  : null,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              formatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                SuggestionFormatter(
                  suggestions: getHints,
                  afterClearSuggestionText: (t) => t,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputGrid({
    required Widget Function(int index) fieldBuilder,
    int columns = 2,
    double horizontalSpacing = 12,
    double verticalSpacing = 16,
  }) {
    final horizontalSpacer = CrystalDivider(width: horizontalSpacing);
    final verticalSpacer = CrystalDivider(height: verticalSpacing);

    final rowsInColumn = (wordsCount / columns).ceil();

    final children = <Widget>[];

    for (int columnIndex = 0; columnIndex < columns; columnIndex++) {
      final fieldsCount = math.min(rowsInColumn, wordsCount - (rowsInColumn * columnIndex));

      final fields = <Widget>[];

      for (int fieldIndex = 0; fieldIndex < fieldsCount; fieldIndex++) {
        final displayIndex = rowsInColumn * columnIndex + fieldIndex;
        final field = fieldBuilder(displayIndex);
        fields.add(field);
        if (fieldIndex < fieldsCount - 1) {
          fields.add(verticalSpacer);
        }
      }

      final column = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: fields,
      );
      children.add(Expanded(child: column));

      if (columnIndex < columns - 1) {
        children.add(horizontalSpacer);
      }
    }

    return Row(children: children);
  }

  Widget buildActions() => ValueListenableBuilder<bool>(
        valueListenable: isFormValid,
        builder: (context, value, child) {
          final bottomPadding = math.max(
            getKeyboardInsetsBottom(context),
            0,
          );

          final canConfirm = words.every((element) => element.isNotEmpty);

          return AnimatedPadding(
            curve: Curves.decelerate,
            duration: kThemeAnimationDuration,
            padding: EdgeInsets.only(
              bottom: bottomPadding + 12,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: CrystalButton(
                key: ValueKey(canConfirm),
                enabled: canConfirm,
                text: LocaleKeys.actions_confirm.tr(),
                onTap: () => onConfirm(words),
              ),
            ),
          );
        },
      );

  String? validateWord(String? value) {
    final text = value ?? '';
    final isValid = text.isEmpty || getHints(text).isNotEmpty;
    if (isValid) {
      return text;
    }
    return null;
  }

  Future<List<String>?> getWordsFromClipboard() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);

    final words = <String>[...clipboard?.text?.split(' ') ?? []];

    if (words.isNotEmpty && words.length == wordsCount) {
      for (final word in words) {
        if (getHints(word).isEmpty) {
          words.clear();
          break;
        }
      }
    } else {
      words.clear();
    }

    if (words.isNotEmpty) {
      return words;
    } else {
      return null;
    }
  }

  void requestNextFocus() {
    bool requested = false;

    for (var i = 0; i < wordsCount; i++) {
      requested = words[i].isEmpty;

      if (requested) {
        requestFocus(i);
        break;
      }
    }

    if (!requested) {
      FocusScope.of(context).unfocus();
    }
  }

  void requestFocus(int index) {
    if (index < 0 || index > focuses.length) {
      FocusScope.of(context).unfocus();
    }

    if (focuses[index].hasFocus) {
      return;
    } else {
      focuses[index].requestFocus();
    }
  }

  void onConfirm(List<String> words) {
    FocusScope.of(context).unfocus();
    bloc.add(PhraseImportEvent.submit(words));
  }
}
