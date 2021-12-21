import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/blocs/account/accounts_bloc.dart';
import '../../../../domain/blocs/application_flow_bloc.dart';
import '../../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../../../domain/blocs/connection_bloc.dart';
import '../../../../domain/blocs/key/keys_bloc.dart';
import '../../../../injection.dart';
import '../../domain/blocs/account/browser_accounts_bloc.dart';
import '../../domain/blocs/account/browser_current_account_bloc.dart';
import '../../domain/blocs/account/current_account_bloc.dart';
import '../../domain/blocs/external_accounts_bloc.dart';
import '../../domain/blocs/public_keys_labels_bloc.dart';

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
          BlocProvider(create: (_) => getIt.get<PublicKeysLabelsBloc>()),
          BlocProvider(create: (_) => getIt.get<BiometryInfoBloc>()),
          BlocProvider(create: (_) => getIt.get<KeysBloc>()),
          BlocProvider(create: (_) => getIt.get<CurrentAccountBloc>()),
          BlocProvider(create: (_) => getIt.get<ExternalAccountsBloc>()),
          BlocProvider(create: (_) => getIt.get<AccountsBloc>()),
          BlocProvider(create: (_) => getIt.get<BrowserAccountsBloc>()),
          BlocProvider(create: (_) => getIt.get<BrowserCurrentAccountBloc>()),
        ],
        child: child,
      );
}
