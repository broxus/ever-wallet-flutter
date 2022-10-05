import 'package:ever_wallet/application/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) => const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: CrystalColor.background,
        ),
      );
}
