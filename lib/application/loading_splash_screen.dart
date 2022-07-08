import 'package:ever_wallet/application/common/theme.dart';
import 'package:flutter/material.dart';

class LoadingSplashScreen extends StatelessWidget {
  const LoadingSplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const Material(
        color: Color(0xFF1a1b39),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: LinearProgressIndicator(
                backgroundColor: Colors.white,
                color: CrystalColor.accent,
              ),
            ),
          ),
        ),
      );
}
