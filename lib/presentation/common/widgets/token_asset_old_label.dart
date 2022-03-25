import 'package:flutter/material.dart';

import '../theme.dart';

class TokenAssetOldLabel extends StatelessWidget {
  const TokenAssetOldLabel({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: CrystalColor.error,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        child: const Text(
          'old',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      );
}
