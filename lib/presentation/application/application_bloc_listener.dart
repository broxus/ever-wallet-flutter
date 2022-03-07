import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/application_flow_state.dart';
import '../../data/repositories/biometry_repository.dart';
import '../../injection.dart';
import '../../providers/common/application_flow_provider.dart';
import '../routes/router.gr.dart';

class ApplicationBlocListener extends StatefulWidget {
  final AppRouter appRouter;
  final Widget child;

  const ApplicationBlocListener({
    Key? key,
    required this.appRouter,
    required this.child,
  }) : super(key: key);

  @override
  _ApplicationBlocListenerState createState() => _ApplicationBlocListenerState();
}

class _ApplicationBlocListenerState extends State<ApplicationBlocListener> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) getIt.get<BiometryRepository>().checkBiometryAvailability();
  }

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          ref.listen<ApplicationFlowState>(
            applicationFlowProvider,
            (previous, next) => next.when(
              loading: () => widget.appRouter.root.pushAndPopUntil(
                const LoadingRoute(),
                predicate: (route) => false,
              ),
              welcome: () => widget.appRouter.root.pushAndPopUntil(
                const WelcomeRouterRoute(),
                predicate: (route) => false,
              ),
              home: () => widget.appRouter.root.pushAndPopUntil(
                const MainRouterRoute(),
                predicate: (route) => false,
              ),
            ),
          );

          return widget.child;
        },
      );
}
