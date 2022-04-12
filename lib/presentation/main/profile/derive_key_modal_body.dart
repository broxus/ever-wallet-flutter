import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../injection.dart';
import '../../../../../data/repositories/keys_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../../generated/codegen_loader.g.dart';
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

  static String get title => LocaleKeys.derive_enter_password.tr();

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
