import 'dart:async';

import 'package:ever_wallet/application/application.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppLifecycleWrapper extends StatefulWidget {
  const AppLifecycleWrapper({
    required this.child,
    Key? key,
  }) : super(key: key);
  final Widget child;

  @override
  State<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper> {
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    // _subscription = context.read<KeysRepository>().keysStream.listen((keys) {
    //   if (keys.isEmpty) {
    //     context
    //         .read<GlobalKey<NavigatorState>>()
    //         .currentState
    //         ?.pushNamedAndRemoveUntil(AppRouter.onboarding, (route) => false);
    //   }
    // });
  }

  @override
  void dispose() {
    // _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
