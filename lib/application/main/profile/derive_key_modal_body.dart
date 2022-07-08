import 'package:ever_wallet/application/common/widgets/crystal_flushbar.dart';
import 'package:ever_wallet/application/main/common/password_input_modal_body.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeriveKeyModalBody extends StatefulWidget {
  final String publicKey;
  final String? name;

  const DeriveKeyModalBody({
    Key? key,
    required this.publicKey,
    required this.name,
  }) : super(key: key);

  static String title(BuildContext context) => AppLocalizations.of(context)!.derive_enter_password;

  @override
  _DeriveKeyModalBodyState createState() => _DeriveKeyModalBodyState();
}

class _DeriveKeyModalBodyState extends State<DeriveKeyModalBody> {
  @override
  Widget build(BuildContext context) => PasswordInputModalBody(
        onSubmit: (password) async {
          try {
            await context.read<KeysRepository>().deriveKey(
                  name: widget.name,
                  publicKey: widget.publicKey,
                  password: password,
                );

            if (!mounted) return;

            Navigator.of(context).pop();
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
