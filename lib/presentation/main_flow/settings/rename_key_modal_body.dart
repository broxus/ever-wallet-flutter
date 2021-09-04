import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../domain/blocs/key/key_update_bloc.dart';
import '../../../injection.dart';
import '../../design/design.dart';

class RenameKeyModalBody extends StatefulWidget {
  final KeySubject keySubject;

  const RenameKeyModalBody({
    Key? key,
    required this.keySubject,
  }) : super(key: key);

  @override
  _RenameKeyModalBodyState createState() => _RenameKeyModalBodyState();
}

class _RenameKeyModalBodyState extends State<RenameKeyModalBody> {
  final controller = TextEditingController();
  late KeyUpdateBloc bloc = getIt.get<KeyUpdateBloc>();

  @override
  void dispose() {
    controller.dispose();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<KeyUpdateBloc, KeyUpdateState>(
        bloc: bloc,
        listener: (context, state) {
          state.map(
            success: (success) {
              context.router.navigatorKey.currentState?.pop();
              return showCrystalFlushbar(
                context,
                message: LocaleKeys.rename_key_modal_message_success.tr(),
              );
            },
            error: (error) => showErrorCrystalFlushbar(context, message: error.info),
            initial: (_) => null,
          );
        },
        child: getBody(),
      );

  Widget getBody() => SafeArea(
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
                    : () {
                        bloc.add(KeyUpdateEvent.rename(
                          keySubject: widget.keySubject,
                          name: value.text,
                        ));
                      },
              ),
            )
          ],
        ),
      );
}
