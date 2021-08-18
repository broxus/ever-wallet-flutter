import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/blocs/application_flow_bloc.dart';
import '../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../router.gr.dart';

class ApplicationListener extends StatefulWidget {
  final AppRouter appRouter;
  final Widget Function(BuildContext) builder;

  const ApplicationListener({
    required this.appRouter,
    required this.builder,
  });

  @override
  _ApplicationListenerState createState() => _ApplicationListenerState();
}

class _ApplicationListenerState extends State<ApplicationListener> with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.resumed) {
      context.read<BiometryInfoBloc>().add(const BiometryInfoEvent.checkBiometryAvailability());
    }
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
        listeners: [
          _getApplicationFlowListener(context),
        ],
        child: widget.builder(context),
      );

  BlocListener _getApplicationFlowListener(BuildContext context) =>
      BlocListener<ApplicationFlowBloc, ApplicationFlowState>(
        listener: (context, state) {
          state.when(
            loading: () => pushAsRoot(const LoadingScreenRoute()),
            welcome: () => pushAsRoot(const WelcomeFlowRoute()),
            home: () => pushAsRoot(const MainFlowRoute()),
          );
        },
      );

  Future<void> pushAsRoot(PageRouteInfo route) => widget.appRouter.pushAndPopUntil(
        route,
        predicate: (route) => false,
      );
}
