import 'package:auto_route/auto_route.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../domain/constants/phrase_generation.dart';
import '../../router.gr.dart';
import '../design/design.dart';
import '../welcome/widget/welcome_scaffold.dart';

class SeedPhraseSaveScreen extends StatefulWidget {
  final String seedName;

  const SeedPhraseSaveScreen({required this.seedName});

  @override
  _SeedPhraseSaveScreenState createState() => _SeedPhraseSaveScreenState();
}

class _SeedPhraseSaveScreenState extends State<SeedPhraseSaveScreen> {
  final _scrollController = ScrollController();
  final key = generateKey(defaultMnemonicType);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WelcomeScaffold(
        headline: LocaleKeys.seed_phrase_save_screen_title.tr(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FadingEdgeScrollView.fromSingleChildScrollView(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          top: 20.0,
                          bottom: 28.0,
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
            offset: const Offset(0.0, 1.0),
            duration: const Duration(milliseconds: 350),
            delay: const Duration(seconds: 1),
            child: CrystalButton(
              text: LocaleKeys.seed_phrase_save_screen_action_confirm.tr(),
              onTap: () => context.router.push(SeedPhraseCheckScreenRoute(
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
              onTap: () => _onCopyPhrase()),
        ],
      );

  Future<void> _onCopyPhrase() async {
    await Clipboard.setData(ClipboardData(text: key.words.join(' ')));
    CrystalFlushbar.show(
      context,
      message: LocaleKeys.seed_phrase_save_screen_message_copied.tr(),
    );
  }
}
