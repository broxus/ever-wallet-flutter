import 'package:flutter/material.dart';

import '../../../../../../injection.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../../logger.dart';
import '../../../design/design.dart';
import '../../../design/widgets/crystal_flushbar.dart';
import '../../../design/widgets/custom_elevated_button.dart';

class RemoveSeedPhraseModalBody extends StatefulWidget {
  final String publicKey;

  const RemoveSeedPhraseModalBody({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  static String get title => LocaleKeys.remove_seed_modal_title.tr();

  @override
  _RemoveSeedPhraseModalBodyState createState() => _RemoveSeedPhraseModalBodyState();
}

class _RemoveSeedPhraseModalBodyState extends State<RemoveSeedPhraseModalBody> {
  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              LocaleKeys.remove_seed_modal_description.tr(),
              style: const TextStyle(
                fontSize: 16,
                color: CrystalColor.fontDark,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 24),
            CustomElevatedButton(
              onPressed: () async {
                try {
                  await getIt.get<KeysRepository>().removeKey(
                        widget.publicKey,
                      );

                  context.router.navigatorKey.currentState?.pop();
                } catch (err, st) {
                  logger.e(err, err, st);

                  await showCrystalFlushbar(
                    context,
                    message: err.toString(),
                  );
                }
              },
              text: LocaleKeys.remove_seed_modal_actions_remove.tr(),
            ),
          ],
        ),
      );
}
