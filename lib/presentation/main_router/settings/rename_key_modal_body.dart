import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/blocs/key/key_update_bloc.dart';
import '../../../injection.dart';
import '../../design/design.dart';

class RenameKeyModalBody extends StatefulWidget {
  final String publicKey;

  const RenameKeyModalBody({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  @override
  _RenameKeyModalBodyState createState() => _RenameKeyModalBodyState();
}

class _RenameKeyModalBodyState extends State<RenameKeyModalBody> {
  final controller = TextEditingController();
  final bloc = getIt.get<KeyUpdateBloc>();

  @override
  void dispose() {
    controller.dispose();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CrystalDivider(height: 20),
            CrystalTextFormField(
              controller: controller,
              autofocus: true,
              formatters: [LengthLimitingTextInputFormatter(50)],
              hintText: LocaleKeys.new_seed_name_hint.tr(),
            ),
            const CrystalDivider(height: 24),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => CrystalButton(
                text: LocaleKeys.rename_key_modal_actions_rename.tr(),
                onTap: value.text.isEmpty
                    ? null
                    : () async {
                        bloc.add(KeyUpdateEvent.rename(
                          publicKey: widget.publicKey,
                          name: value.text,
                        ));

                        final result = await bloc.stream.first;

                        if (result is KeyUpdateStateSuccess) {
                          context.router.navigatorKey.currentState?.pop();
                          showCrystalFlushbar(
                            context,
                            message: LocaleKeys.rename_key_modal_message_success.tr(),
                          );
                        } else if (result is KeyUpdateStateError) {
                          showErrorCrystalFlushbar(
                            context,
                            message: result.exception.toString(),
                          );
                        }
                      },
              ),
            )
          ],
        ),
      );
}
