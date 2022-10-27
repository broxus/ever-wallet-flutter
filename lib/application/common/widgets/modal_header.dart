import 'package:ever_wallet/application/common/general/button/primary_icon_button.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/material.dart';

class ModalHeader extends StatelessWidget {
  final String text;
  final VoidCallback? onCloseButtonPressed;

  const ModalHeader({
    super.key,
    required this.text,
    this.onCloseButtonPressed,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(text, style: StylesRes.header3Text.copyWith(color: ColorsRes.black)),
            ),
            PrimaryIconButton(
              outerPadding: EdgeInsets.zero,
              icon: const Icon(Icons.close, color: ColorsRes.black),
              onPressed: onCloseButtonPressed,
            ),
          ],
        ),
      );
}
