import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/design.dart';
import '../../design/widget/crystal_button.dart';
import '../../design/widget/crystal_scaffold.dart';

class SeedPhraseExportPage extends StatefulWidget {
  final List<String> phrase;

  const SeedPhraseExportPage({
    Key? key,
    required this.phrase,
  }) : super(key: key);

  @override
  _SeedPhraseExportPageState createState() => _SeedPhraseExportPageState();
}

class _SeedPhraseExportPageState extends State<SeedPhraseExportPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CrystalScaffold(
        headline: LocaleKeys.seed_phrase_save_screen_title.tr(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              buildBody(),
              Align(
                alignment: Alignment.bottomCenter,
                child: buildActions(),
              ),
            ],
          ),
        ),
      );

  Widget buildBody() => FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(
            top: 20,
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
          onTap: () => onCopyPhrase(),
        ),
      );

  Future<void> onCopyPhrase() async {
    await Clipboard.setData(ClipboardData(text: widget.phrase.join(' ')));

    showCrystalFlushbar(
      context,
      message: LocaleKeys.seed_phrase_save_screen_message_copied.tr(),
    );
  }
}
