import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/blocs/application_flow_bloc.dart';
import '../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../injection.dart';

class ApplicationProvider extends StatelessWidget {
  final Widget child;

  const ApplicationProvider({
    required this.child,
  });

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt.get<ApplicationFlowBloc>()),
          BlocProvider(create: (_) => getIt.get<BiometryInfoBloc>()),
        ],
        child: child,
      );
}
