import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ErrorSplashScreen extends StatelessWidget {
  final String text;

  const ErrorSplashScreen({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF1a1b39),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 24,
                  color: Colors.white,
                ),
                const Gap(16),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
