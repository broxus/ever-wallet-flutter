import 'package:flutter/material.dart';

import '../../../../../../../../injection.dart';
import '../../../../../../../data/repositories/keys_repository.dart';
import '../../../../../../../injection.dart';
import '../../../../../../data/repositories/keys_repository.dart';
import '../../../../../../logger.dart';
import '../../../../../data/extensions.dart';
import '../../../../common/widgets/crystal_flushbar.dart';
import '../../../../common/widgets/ew_bottom_sheet.dart';
import '../../../../util/extensions/context_extensions.dart';
import '../../../common/input_password_modal_body.dart';
import 'seed_phrase_export_sheet.dart';

class ExportSeedPhraseModalBody extends StatefulWidget {
  final String publicKey;

  const ExportSeedPhraseModalBody({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  @override
  _ExportSeedPhraseModalBodyState createState() => _ExportSeedPhraseModalBodyState();
}

class _ExportSeedPhraseModalBodyState extends State<ExportSeedPhraseModalBody> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => InputPasswordModalBody(
        onSubmit: (password) async {
          try {
            final phrase = await getIt.get<KeysRepository>().exportKey(
                  publicKey: widget.publicKey,
                  password: password,
                );

            if (!mounted) return;
            final navigator = Navigator.of(context);
            navigator.pop();
            showEWBottomSheet<void>(
              context,
              title: context.localization.save_seed_phrase,
              body: SeedPhraseExportSheet(phrase: phrase),
            );
          } catch (err, st) {
            logger.e(err, err, st);

            await showFlushbar(
              context,
              message: (err as Exception).toUiMessage(),
            );
          }
        },
        publicKey: widget.publicKey,
      );
}
