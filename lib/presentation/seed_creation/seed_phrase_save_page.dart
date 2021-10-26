import 'package:auto_route/auto_route.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../domain/constants/phrase_generation.dart';
import '../design/design.dart';
import '../design/widget/crystal_scaffold.dart';
import '../router.gr.dart';

class SeedPhraseSavePage extends StatefulWidget {
  final String? seedName;

  const SeedPhraseSavePage({
    Key? key,
    this.seedName,
  }) : super(key: key);

  @override
  _SeedPhraseSavePageState createState() => _SeedPhraseSavePageState();
}

class _SeedPhraseSavePageState extends State<SeedPhraseSavePage> {
  final scrollController = ScrollController();
  final key = generateKey(kDefaultMnemonicType);

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CrystalScaffold(
        headline: LocaleKeys.seed_phrase_save_screen_title.tr(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FadingEdgeScrollView.fromSingleChildScrollView(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.only(
                          top: 20,
                          bottom: 28,
                        ),
                        child: WordsGridWidget(key.words),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: buildActions(),
              ),
            ],
          ),
        ),
      );

  Widget buildActions() => Column(
        children: [
          AnimatedAppearance(
            offset: const Offset(0, 1),
            duration: const Duration(milliseconds: 350),
            delay: const Duration(seconds: 1),
            child: CrystalButton(
              text: LocaleKeys.seed_phrase_save_screen_action_confirm.tr(),
              onTap: () => context.router.push(SeedPhraseCheckRoute(
                phrase: key.words,
                seedName: widget.seedName,
              )),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          CrystalButton(
            type: CrystalButtonType.outline,
            text: LocaleKeys.seed_phrase_save_screen_action_copy.tr(),
            onTap: () => onCopyPhrase(),
          ),
        ],
      );

  Future<void> onCopyPhrase() async {
    await Clipboard.setData(ClipboardData(text: key.words.join(' ')));
    showCrystalFlushbar(
      context,
      message: LocaleKeys.seed_phrase_save_screen_message_copied.tr(),
    );
  }
}
