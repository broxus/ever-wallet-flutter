import 'package:ever_wallet/application/common/widgets/crystal_flushbar.dart';
import 'package:ever_wallet/application/main/common/password_input_modal_body.dart';
import 'package:ever_wallet/application/main/profile/seed_phrase_export_page.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExportSeedPhraseModalBody extends StatefulWidget {
  final String publicKey;

  const ExportSeedPhraseModalBody({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  static String title(BuildContext context) => AppLocalizations.of(context)!.export_enter_password;

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
  Widget build(BuildContext context) => PasswordInputModalBody(
        onSubmit: (password) async {
          try {
            final phrase = await context.read<KeysRepository>().exportKey(
                  publicKey: widget.publicKey,
                  password: password,
                );

            if (!mounted) return;

            Navigator.of(context).pop();
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(
                builder: (context) => SeedPhraseExportPage(phrase: phrase),
              ),
            );
          } catch (err, st) {
            logger.e(err, err, st);

            await showCrystalFlushbar(
              context,
              message: (err as Exception).toUiMessage(),
            );
          }
        },
        publicKey: widget.publicKey,
      );
}
