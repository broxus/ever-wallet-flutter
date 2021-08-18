import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../domain/blocs/account/account_creation_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../../../design/extension.dart';
import '../../../design/widget/crystal_bottom_sheet.dart';
import 'add_account_flow/add_account_name.dart';

class CreatingWalletBody extends StatefulWidget {
  final PanelController modalController;
  final KeySubject keySubject;

  const CreatingWalletBody({
    Key? key,
    required this.modalController,
    required this.keySubject,
  }) : super(key: key);

  @override
  _CreatingWalletBodyState createState() => _CreatingWalletBodyState();
}

class _CreatingWalletBodyState extends State<CreatingWalletBody> {
  late final AccountCreationBloc accountCreationBloc;
  final selectedType = ValueNotifier<WalletType?>(null);

  @override
  void initState() {
    super.initState();
    accountCreationBloc = getIt.get<AccountCreationBloc>(param1: widget.keySubject);
  }

  @override
  void dispose() {
    accountCreationBloc.close();
    selectedType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedAppearance(
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          child: BlocConsumer<AccountCreationBloc, AccountCreationState>(
            listener: (context, state) async {},
            bloc: accountCreationBloc,
            builder: (context, state) => state.maybeWhen(
              options: (added, available) => buildBody(available),
              orElse: () => const SizedBox(height: 180),
            ),
          ),
        ),
      );

  Widget buildBody(List<WalletType> options) => ValueListenableBuilder<WalletType?>(
        valueListenable: selectedType,
        builder: (context, value, child) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocaleKeys.create_account_modal_title.tr(),
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                color: CrystalColor.fontDark,
              ),
            ),
            const CrystalDivider(height: 24.0),
            CrystalValueSelector<WalletType>(
              selectedValue: value ?? options.first,
              options: options,
              nameOfOption: (o) => o.describe(),
              onSelect: (contract) => selectedType.value = contract,
            ),
            const CrystalDivider(height: 16),
            CrystalButton(
              onTap: () async {
                final name = await CrystalBottomSheet.show<String>(
                  context,
                  title: AddAccountName.title,
                  body: AddAccountName(
                    onAddTap: (name) => context.router.pop<String>(name),
                  ),
                );

                if (name != null) {
                  accountCreationBloc.add(AccountCreationEvent.createAccount(
                    name: name,
                    walletType: value ?? options.first,
                  ));
                }
              },
              text: LocaleKeys.create_account_modal_actions_add.tr(),
            ),
          ],
        ),
      );
}
