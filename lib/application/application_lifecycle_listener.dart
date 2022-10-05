import 'package:ever_wallet/data/repositories/app_lifecycle_state_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApplicationLifecycleListener extends StatefulWidget {
  final Widget Function() builder;

  const ApplicationLifecycleListener({
    super.key,
    required this.builder,
  });

  @override
  State<ApplicationLifecycleListener> createState() => _ApplicationLifecycleListener();
}

class _ApplicationLifecycleListener extends State<ApplicationLifecycleListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    context.read<AppLifecycleStateRepository>().updateAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) => widget.builder();
}
