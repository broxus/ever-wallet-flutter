import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/blocs/account/accounts_bloc.dart';
import '../../../../domain/blocs/application_flow_bloc.dart';
import '../../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../../../domain/blocs/connection_bloc.dart';
import '../../../../domain/blocs/key/keys_bloc.dart';
import '../../../../injection.dart';

class ApplicationBlocProvider extends StatelessWidget {
  final Widget child;

  const ApplicationBlocProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt.get<ApplicationFlowBloc>()),
          BlocProvider(create: (_) => getIt.get<ConnectionBloc>()),
          BlocProvider(create: (_) => getIt.get<BiometryInfoBloc>()),
          BlocProvider(create: (_) => getIt.get<KeysBloc>()),
          BlocProvider(create: (_) => getIt.get<AccountsBloc>()),
        ],
        child: child,
      );
}