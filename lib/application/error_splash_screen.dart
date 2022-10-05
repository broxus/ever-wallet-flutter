import 'package:ever_wallet/application/onboarding/widgets/splash_screen.dart';
import 'package:flutter/material.dart';

class ErrorSplashScreen extends StatelessWidget {
  final String text;

  const ErrorSplashScreen({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => OnboardingSplashScreen(error: text);
}
