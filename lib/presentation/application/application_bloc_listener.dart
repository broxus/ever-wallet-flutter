import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/blocs/application_flow_bloc.dart';
import '../../../../domain/blocs/biometry/biometry_info_bloc.dart';
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
    if (state == AppLifecycleState.resumed) {
      context.read<BiometryInfoBloc>().add(const BiometryInfoEvent.checkAvailability());
    }
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
        listeners: [
          applicationFlowListener(context),
        ],
        child: widget.child,
      );

  BlocListener applicationFlowListener(BuildContext context) => BlocListener<ApplicationFlowBloc, ApplicationFlowState>(
        listener: (context, state) => state.when(
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
}
