import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../design/design.dart';

class NewAssetLayout extends StatefulWidget {
  final ScrollController controller;
  final void Function(String) onSave;

  const NewAssetLayout({
    Key? key,
    required this.controller,
    required this.onSave,
  }) : super(key: key);

  @override
  _NewAssetLayoutState createState() => _NewAssetLayoutState();
}

class _NewAssetLayoutState extends State<NewAssetLayout> {
  final textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: FadingEdgeScrollView.fromSingleChildScrollView(
                  child: SingleChildScrollView(
                    controller: widget.controller,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24.0,
                      horizontal: 16.0,
                    ),
                    child: Form(
                      key: formKey,
                      child: CrystalTextField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value != null && validateAddress(value)) {
                            return null;
                          } else {
                            return LocaleKeys.fields_validation_errors_wrong_address.tr();
                          }
                        },
                        controller: textEditingController,
                        autocorrect: false,
                        keyboardType: TextInputType.name,
                        inputAction: TextInputAction.done,
                        scrollPadding: const EdgeInsets.all(24.0),
                        hintText: LocaleKeys.add_assets_modal_create_layout_contract_hint.tr(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: getProceedButton(),
          ),
        ],
      );

  Widget getProceedButton() => ValueListenableBuilder<TextEditingValue>(
        valueListenable: textEditingController,
        builder: (context, value, _) {
          if (value.text.isNotEmpty && validateAddress(value.text)) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CrystalButton(
                text: LocaleKeys.actions_proceed.tr(),
                onTap: () {
                  final address = value.text;
                  context.router.pop();
                  widget.onSave(address);
                },
              ),
            );
          }
          return const SizedBox();
        },
      );
}
