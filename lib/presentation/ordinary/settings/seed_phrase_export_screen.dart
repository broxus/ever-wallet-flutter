import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/design.dart';
import '../../design/widget/button.dart';
import '../../welcome/widget/welcome_scaffold.dart';

class SeedPhraseExportScreen extends StatefulWidget {
  final List<String> phrase;

  const SeedPhraseExportScreen({
    Key? key,
    required this.phrase,
  }) : super(key: key);

  @override
  _SeedPhraseExportScreenState createState() => _SeedPhraseExportScreenState();
}

class _SeedPhraseExportScreenState extends State<SeedPhraseExportScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WelcomeScaffold(
        allowIosBackSwipe: false,
        headline: LocaleKeys.seed_phrase_save_screen_title.tr(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Stack(
            children: [
              getBody(),
              Align(
                alignment: Alignment.bottomCenter,
                child: buildActions(),
              ),
            ],
          ),
        ),
      );

  Widget getBody() => FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(
            top: 20.0,
            bottom: 28.0 + CrystalButton.kHeight,
          ),
          child: WordsGridWidget(widget.phrase),
        ),
      );

  Widget buildActions() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CrystalButton(
            type: CrystalButtonType.outline,
            text: LocaleKeys.seed_phrase_save_screen_action_copy.tr(),
            onTap: () => _onCopyPhrase()),
      );

  Future<void> _onCopyPhrase() async {
    await Clipboard.setData(ClipboardData(text: widget.phrase.join(' ')));
    CrystalFlushbar.show(
      context,
      message: LocaleKeys.seed_phrase_save_screen_message_copied.tr(),
    );
  }
}
