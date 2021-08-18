import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../domain/blocs/account/account_removement_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';

class AccountRemovementBody extends StatefulWidget {
  final SubscriptionSubject subscriptionSubject;

  const AccountRemovementBody({
    Key? key,
    required this.subscriptionSubject,
  }) : super(key: key);

  static String get title => LocaleKeys.actions_remove_account.tr();

  @override
  _AccountRemovementBodyState createState() => _AccountRemovementBodyState();
}

class _AccountRemovementBodyState extends State<AccountRemovementBody> {
  final bloc = getIt.get<AccountRemovementBloc>();

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocListener<AccountRemovementBloc, AccountRemovementState>(
            bloc: bloc,
            listener: (context, state) => state.maybeWhen(
              success: () => context.router.navigatorKey.currentState?.pop(),
              orElse: () => null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  LocaleKeys.remove_account_modal_description.tr(),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: CrystalColor.fontDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const CrystalDivider(height: 24),
                CrystalButton(
                  text: LocaleKeys.actions_remove_account.tr(),
                  onTap: () =>
                      bloc.add(AccountRemovementEvent.removeAccount(widget.subscriptionSubject.value.accountSubject)),
                ),
                const CrystalDivider(height: 24),
              ],
            ),
          ),
        ),
      );
}
