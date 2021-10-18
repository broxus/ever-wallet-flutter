import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../domain/blocs/account/account_creation_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../../../design/utils.dart';
import '../../../design/widget/crystal_scaffold.dart';
import '../../../router.gr.dart';

class NewAccountTypePage extends StatefulWidget {
  final String publicKey;
  final String accountName;

  const NewAccountTypePage({
    Key? key,
    required this.publicKey,
    required this.accountName,
  }) : super(key: key);

  @override
  _NewAccountTypePageState createState() => _NewAccountTypePageState();
}

class _NewAccountTypePageState extends State<NewAccountTypePage> {
  final selectedWalletType = ValueNotifier<WalletType?>(null);
  final AccountCreationBloc accountCreationBloc = getIt.get<AccountCreationBloc>();

  @override
  void initState() {
    super.initState();
    accountCreationBloc.add(AccountCreationEvent.showOptions(widget.publicKey));
  }

  @override
  void dispose() {
    selectedWalletType.dispose();
    accountCreationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CrystalScaffold(
        onScaffoldTap: FocusScope.of(context).unfocus,
        headline: 'Select wallet type',
        body: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: buildBody(),
        ),
      );

  Widget buildBody() => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Stack(
          children: [
            BlocConsumer<AccountCreationBloc, AccountCreationState>(
              bloc: accountCreationBloc,
              listener: (context, state) => state.maybeWhen(
                options: (added, available) =>
                    selectedWalletType.value = available.firstWhereOrNull((e) => !added.contains(e)),
                orElse: () => null,
              ),
              builder: (context, state) => state.maybeWhen(
                options: (added, available) => ListView.builder(
                  itemCount: available.length,
                  itemBuilder: (BuildContext context, int index) => ValueListenableBuilder<WalletType?>(
                    valueListenable: selectedWalletType,
                    builder: (context, value, child) => Theme(
                      data: ThemeData(),
                      child: RadioListTile<WalletType>(
                        value: available[index],
                        groupValue: value,
                        onChanged:
                            !added.contains(available[index]) ? (value) => selectedWalletType.value = value : null,
                        activeColor: CrystalColor.accent,
                        title: Text('${available[index].describe()}${index == 0 ? ' (default)' : ""}'),
                      ),
                    ),
                  ),
                ),
                orElse: () => const SizedBox(),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: buildActions(),
            ),
          ],
        ),
      );

  Widget buildActions() => ValueListenableBuilder<WalletType?>(
        valueListenable: selectedWalletType,
        builder: (context, value, child) {
          final double bottomPadding = math.max(getKeyboardInsetsBottom(context), 0) + 12;

          return AnimatedPadding(
            curve: Curves.decelerate,
            duration: kThemeAnimationDuration,
            padding: EdgeInsets.only(
              bottom: bottomPadding,
            ),
            child: AnimatedAppearance(
              showing: value != null,
              duration: const Duration(milliseconds: 350),
              child: CrystalButton(
                text: 'Submit',
                onTap: () => onConfirm(value!),
              ),
            ),
          );
        },
      );

  void onConfirm(WalletType walletType) {
    accountCreationBloc.add(AccountCreationEvent.createAccount(
      name: widget.accountName,
      publicKey: widget.publicKey,
      walletType: walletType,
    ));

    context.router.navigate(const WalletRouterRoute());
  }
}
