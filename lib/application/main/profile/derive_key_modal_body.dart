import 'dart:math';

import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/main/common/password_input_modal_body.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeriveKeyModalBody extends StatefulWidget {
  final String publicKey;
  final String? name;

  const DeriveKeyModalBody({
    super.key,
    required this.publicKey,
    required this.name,
  });

  @override
  _DeriveKeyModalBodyState createState() => _DeriveKeyModalBodyState();
}

class _DeriveKeyModalBodyState extends State<DeriveKeyModalBody> {
  @override
  Widget build(BuildContext context) => PasswordInputModalBody(
        onSubmit: (password) async {
          try {
            final keysRepo = context.read<KeysRepository>();
            await keysRepo.deriveKey(
              name: widget.name,
              masterKey: widget.publicKey,
              accountId: keysRepo.keys
                      .where((e) => e.masterKey == widget.publicKey)
                      .map((e) => e.accountId)
                      .reduce(max) +
                  1,
              password: password,
            );

            if (!mounted) return;
            Navigator.of(context).pop();
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
