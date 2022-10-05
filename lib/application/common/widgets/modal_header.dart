import 'package:ever_wallet/application/common/widgets/crystal_title.dart';
import 'package:ever_wallet/application/common/widgets/custom_close_button.dart';
import 'package:flutter/material.dart';

class ModalHeader extends StatelessWidget {
  final String text;
  final void Function()? onCloseButtonPressed;

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
              child: CrystalTitle(
                text: text,
              ),
            ),
            CustomCloseButton(
              onPressed: onCloseButtonPressed,
            ),
          ],
        ),
      );
}
