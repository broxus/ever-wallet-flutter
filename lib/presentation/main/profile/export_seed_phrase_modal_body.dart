import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../injection.dart';
import '../../../../../data/repositories/keys_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../../logger.dart';
import '../../../data/extensions.dart';
import '../../common/widgets/crystal_flushbar.dart';
import '../../router.gr.dart';
import '../common/input_password_modal_body.dart';

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
  Widget build(BuildContext context) => InputPasswordModalBody(
        onSubmit: (password) async {
          try {
            final phrase = await getIt.get<KeysRepository>().exportKey(
                  publicKey: widget.publicKey,
                  password: password,
                );

            context.router.navigatorKey.currentState?.pop();
            context.topRoute.router.navigate(SeedPhraseExportRoute(phrase: phrase));
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
