import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../data/repositories/accounts_repository.dart';
import '../../../../../data/repositories/external_accounts_repository.dart';
import '../../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../../injection.dart';
import '../../../../design/design.dart';
import '../../../../design/widgets/custom_popup_menu.dart';
import '../modals/account_removement_modal/show_account_removement_modal.dart';
import '../modals/custodians_modal/show_custodians_modal.dart';
import '../modals/preferences_modal/show_preferences_modal.dart';

class MoreButton extends StatefulWidget {
  final String address;
  final bool isExternal;
  final String? publicKey;

  const MoreButton({
    Key? key,
    required this.address,
    this.isExternal = false,
    this.publicKey,
  }) : super(key: key);

  @override
  State<MoreButton> createState() => _MoreButtonState();
}

class _MoreButtonState extends State<MoreButton> {
  final bloc = getIt.get<TonWalletInfoBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(TonWalletInfoEvent.load(widget.address));
  }

  @override
  void didUpdateWidget(covariant MoreButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      bloc.add(TonWalletInfoEvent.load(widget.address));
    }
  }

  @override
  void dispose() {
    super.dispose();
    bloc.close();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TonWalletInfoBloc, TonWalletInfo?>(
        bloc: bloc,
        builder: (context, state) => more(state),
      );

  Widget more(TonWalletInfo? state) => CustomPopupMenu(
        items: [
          _Actions.preferences,
          if (state?.custodians?.isNotEmpty ?? false) _Actions.custodians,
          _Actions.removeAccount,
        ]
            .map(
              (e) => Tuple2(
                e.describe(),
                () => onSelected(e),
              ),
            )
            .toList(),
        icon: Container(
          width: 28,
          height: 28,
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: CrystalColor.actionBackground.withOpacity(0.3),
          ),
          child: const Icon(
            Icons.more_horiz,
            color: Colors.white,
          ),
        ),
      );

  void onSelected(_Actions value) {
    switch (value) {
      case _Actions.preferences:
        showPreferencesModal(
          context: context,
          address: widget.address,
          isExternal: widget.isExternal,
          publicKey: widget.publicKey,
        );
        break;
      case _Actions.custodians:
        showCustodiansModal(
          context: context,
          address: widget.address,
        );
        break;
      case _Actions.removeAccount:
        showAccountRemovementDialog(
          context: context,
          address: widget.address,
          onDeletePressed: () async {
            if (!widget.isExternal) {
              await getIt.get<AccountsRepository>().removeAccount(widget.address);
            } else {
              await getIt.get<ExternalAccountsRepository>().removeExternalAccount(
                    address: widget.address,
                  );
            }
          },
        );
        break;
    }
  }
}

enum _Actions {
  preferences,
  custodians,
  removeAccount,
}

extension on _Actions {
  String describe() {
    switch (this) {
      case _Actions.preferences:
        return 'Preferences';
      case _Actions.custodians:
        return 'Custodians';
      case _Actions.removeAccount:
        return 'Remove account';
    }
  }
}
