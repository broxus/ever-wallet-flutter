import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../design/design.dart';

class AddAccountName extends StatefulWidget {
  static String get title => LocaleKeys.wallet_screen_add_account_title.tr();

  const AddAccountName({
    Key? key,
    this.onAddTap,
  }) : super(key: key);

  final void Function(String)? onAddTap;

  @override
  _AddAccountNameState createState() => _AddAccountNameState();
}

class _AddAccountNameState extends State<AddAccountName> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(top: 24, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CrystalTextFormField(
            autofocus: true,
            controller: _textController,
            hintText: '${LocaleKeys.wallet_screen_add_account_hint.tr()}…',
            maxLength: 24,
            formatters: [
              FilteringTextInputFormatter.deny('  ', replacementString: ' '),
            ],
          ),
          const Flexible(child: CrystalDivider(height: 24)),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _textController,
            builder: (context, value, _) => CrystalButton(
              enabled: value.text.trim().isNotEmpty,
              text: LocaleKeys.actions_next.tr(),
              onTap: () => widget.onAddTap?.call(value.text.trim()),
            ),
          ),
        ],
      ),
    );
  }
}
