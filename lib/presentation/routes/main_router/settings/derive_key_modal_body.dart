import 'package:flutter/material.dart';

import '../../../../../../injection.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../design/design.dart';
import '../widgets/input_password_modal_body.dart';

class DeriveKeyModalBody extends StatefulWidget {
  final String publicKey;
  final String? name;

  const DeriveKeyModalBody({
    Key? key,
    required this.publicKey,
    required this.name,
  }) : super(key: key);

  static String get title => LocaleKeys.derive_key_modal_title.tr();

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

            context.router.navigatorKey.currentState?.pop();
          } catch (err) {
            await showCrystalFlushbar(
              context,
              message: err.toString(),
            );
          }
        },
        publicKey: widget.publicKey,
      );
}
