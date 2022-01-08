import 'package:flutter/material.dart';

class ApplicationBlocProvider extends StatelessWidget {
  final Widget child;

  const ApplicationBlocProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => child;
}
