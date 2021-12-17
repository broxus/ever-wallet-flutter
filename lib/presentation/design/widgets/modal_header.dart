import 'package:flutter/material.dart';

import 'crystal_title.dart';
import 'custom_close_button.dart';

class ModalHeader extends StatelessWidget {
  final String text;

  const ModalHeader({
    Key? key,
    required this.text,
  }) : super(key: key);

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
            const CustomCloseButton(),
          ],
        ),
      );
}
