import 'package:flutter/material.dart';

import '../../../../../../injection.dart';
import '../../../../../data/repositories/keys_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../../logger.dart';
import '../../../data/extensions.dart';
import '../../common/widgets/crystal_flushbar.dart';
import '../common/input_password_modal_body.dart';

class DeriveKeyModalBody extends StatefulWidget {
  final String publicKey;
  final String? name;

  const DeriveKeyModalBody({
    Key? key,
    required this.publicKey,
    required this.name,
  }) : super(key: key);

  @override
  _DeriveKeyModalBodyState createState() => _DeriveKeyModalBodyState();
}

class _DeriveKeyModalBodyState extends State<DeriveKeyModalBody> {
  @override
  Widget build(BuildContext context) => InputPasswordModalBody(
        onSubmit: (password) async {
          try {
            await getIt.get<KeysRepository>().deriveKey(
                  name: widget.name,
                  publicKey: widget.publicKey,
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
