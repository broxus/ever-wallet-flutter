import 'dart:math' as math;

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
import '../welcome/widget/welcome_scaffold.dart';

class SeedPhraseImportScreen extends StatefulWidget {
  final String seedName;
  final bool isLegacy;

  const SeedPhraseImportScreen({
    required this.seedName,
    required this.isLegacy,
  });

  @override
  _SeedPhraseImportScreenState createState() => _SeedPhraseImportScreenState();
}

class _SeedPhraseImportScreenState extends State<SeedPhraseImportScreen> {
  final ValueNotifier<bool> _isPasteButton = ValueNotifier<bool>(true);

  final fieldLayoutScrollController = ScrollController();
  late final int wordsCount;
  final bloc = getIt.get<PhraseImportBloc>();
  late final List<String> words;
  late final List<FocusNode> focuses;
  late final List<TextEditingController> controllers;
  final _clipboard = ValueNotifier<List<String>?>(null);

  @override
  void initState() {
    super.initState();
    wordsCount = widget.isLegacy ? 24 : 12;
    words = List<String>.generate(wordsCount, (_) => '');
    focuses = List.generate(wordsCount, (_) => FocusNode());
    controllers = List.generate(wordsCount, (_) => TextEditingController());
  }

  @override
  void didChangeDependencies() {
    _clipboardListener();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    for (int i = 0; i < wordsCount; i++) {
      focuses[i].dispose();
      controllers[i].dispose();
    }
    fieldLayoutScrollController.dispose();
    _clipboard.dispose();
    super.dispose();
  }

  Future<void> _clipboardListener() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    bool isValid = false;
    final List<String>? words = clipboard?.text?.split(' ');

    if (words != null && words.isNotEmpty && (words.length == wordsCount || words.length == 12)) {
      isValid = true;

      for (final String word in words) {
        if (getHints(word).isEmpty) {
          isValid = false;
          break;
        }
      }
    }
    if (isValid) {
      _clipboard.value = words;
    } else {
      _clipboard.value = null;
    }
  }

  @override
  Widget build(BuildContext context) => BlocListener<PhraseImportBloc, PhraseImportState>(
        bloc: bloc,
        listener: (context, state) => state.when(
          initial: () => null,
          success: (phrase) => context.router.push(
            PasswordCreationScreenRoute(
              phrase: words.where((element) => element.isNotEmpty).toList(),
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
        child: WelcomeScaffold(
          actions: ValueListenableBuilder<bool>(
            valueListenable: _isPasteButton,
            builder: (ctx, value, child) {
              return value ? getPasteButton() : getClearButton();
            },
          ),
          onScaffoldTap: unfocus,
          headlineSize: 28.0,
          headline: LocaleKeys.seed_phrase_import_screen_title.tr(),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

  Widget getPasteButton() {
    return ValueListenableBuilder<List<String>?>(
        valueListenable: _clipboard,
        builder: (
          BuildContext context,
          List<String>? _words,
          _,
        ) {
          if (_words != null) {
            return ExpandTapWidget(
              onTap: () {
                _words.asMap().forEach((index, word) {
                  controllers[index].text = word;
                  words[index] = word;
                });
                _isPasteButton.value = !_isPasteButton.value;
              },
              tapPadding: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 12.0),
                child: SizedBox(
                  height: 24,
                  child: Center(
                    child: Text(
                      LocaleKeys.actions_paste.tr(),
                      style: const TextStyle(
                        fontSize: 14.0,
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
          }
          return const SizedBox();
        });
  }

  Widget getClearButton() {
    return ExpandTapWidget(
      onTap: () {
        for (final controller in controllers) {
          controller.text = '';
        }

        for (var index = 0; index < words.length; index++) {
          words[index] = '';
        }

        _isPasteButton.value = !_isPasteButton.value;
      },
      tapPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, top: 12.0),
        child: SizedBox(
          height: 24,
          child: Center(
            child: Text(
              LocaleKeys.actions_clear.tr(),
              style: const TextStyle(
                fontSize: 14.0,
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
  }

  Widget buildFieldLayout() {
    final bottomKeyboardPadding = math.max(
      getKeyboardInsetsBottom(context),
      0,
    );
    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        controller: fieldLayoutScrollController,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          top: 20.0,
          bottom: bottomKeyboardPadding + CrystalButton.kHeight + 24.0,
        ),
        child: buildInputGrid(
          columns: 1,
          fieldBuilder: (index) => CrystalTextField(
            maxLength: 24,
            enableInteractiveSelection: false,
            focusNode: focuses[index],
            controller: controllers[index],
            onTap: () {
              if (!focuses[index].hasFocus) {
                prepareController(index);
              }
            },
            autocorrect: false,
            onEditingComplete: _requestNextFocus,
            onFieldSubmitted: (_) => _requestNextFocus(),
            scrollPadding: EdgeInsets.only(
              top: 32.0,
              bottom: bottomKeyboardPadding + CrystalButton.kHeight + 24.0,
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
              maxWidth: 38.0,
              minWidth: 38.0,
            ),
            onChanged: (s) {
              words[index] = validateWord(s) ?? '';
              if (controllers[index].text != '' && _isPasteButton.value) {
                _isPasteButton.value = !_isPasteButton.value;
              } else if (controllers[index].text == '' && !_isPasteButton.value) {
                _isPasteButton.value = !_isPasteButton.value;
              }
            },
            validator: (s) => validateWord(s) == null
                ? LocaleKeys.seed_phrase_import_screen_validation_errors_incorrect_word.tr()
                : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            formatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
              SuggestionFormatter(
                suggestions: getHints,
                afterClearSuggestionText: (t) => BackspaceInputHandler.kBlank + t,
              ),
              BackspaceInputHandler(onClear: () => requestFocus(index - 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputGrid({
    required Widget Function(int index) fieldBuilder,
    int columns = 2,
    double horizontalSpacing = 12.0,
    double verticalSpacing = 16.0,
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

      final column = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: fields);
      children.add(Expanded(child: column));
      if (columnIndex < columns - 1) {
        children.add(horizontalSpacer);
      }
    }

    return Row(children: children);
  }

  Widget buildActions() => AnimatedBuilder(
        animation: Listenable.merge(controllers),
        builder: (context, _) {
          final bottomPadding = math.max(
            getKeyboardInsetsBottom(context),
            0,
          );
          final canConfirm =
              words.sublist(0, wordsCount ~/ 2).every((element) => element.isNotEmpty && element != '') &&
                      words.sublist(wordsCount ~/ 2).every((element) => element.isEmpty) ||
                  words.every((element) => element.isNotEmpty && element != '');

          return AnimatedPadding(
            curve: Curves.decelerate,
            duration: kThemeAnimationDuration,
            padding: EdgeInsets.only(
              bottom: !canConfirm ? 12 : bottomPadding + 12,
            ),
            child: AnimatedAppearance(
              showing: canConfirm || bottomPadding == 0,
              delay: const Duration(milliseconds: 450),
              duration: const Duration(milliseconds: 350),
              child: CrystalButton(
                enabled: canConfirm,
                text: LocaleKeys.actions_confirm.tr(),
                onTap: () => onConfirm(words.where((element) => element.isNotEmpty).toList()),
              ),
            ),
          );
        },
      );

  String? validateWord(String? s) {
    final text = s?.replaceAll(BackspaceInputHandler.kBlank, '') ?? '';
    final isValid = text.isEmpty || getHints(text).isNotEmpty;
    if (isValid) {
      return text;
    }
    return null;
  }

  void unfocus() {
    FocusScope.of(context).unfocus();
    clearBackspaces();
  }

  void clearBackspaces() {
    for (final controller in controllers) {
      controller.text = controller.text.replaceAll(BackspaceInputHandler.kBlank, '');
    }
  }

  void prepareController(int index) {
    clearBackspaces();
    final text = controllers[index].text;
    controllers[index].text = BackspaceInputHandler.kBlank + text;
  }

  void _requestNextFocus() {
    bool requested = false;
    for (var i = 0; i < wordsCount; i++) {
      requested = words[i].isEmpty;
      if (requested) {
        requestFocus(i);
        break;
      }
    }

    if (!requested) unfocus();
  }

  void requestFocus(int index) {
    if (index < 0 || index > wordsCount) {
      unfocus();
    }
    if (focuses[index].hasFocus) return;
    prepareController(index);
    focuses[index].requestFocus();
  }

  void onConfirm(List<String> words) {
    unfocus();
    bloc.add(PhraseImportEvent.submit(words));
  }
}
