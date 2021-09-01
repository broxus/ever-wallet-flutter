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
import '../../../welcome/widget/welcome_scaffold.dart';

class NewAccountTypeScreen extends StatefulWidget {
  final KeySubject keySubject;
  final String accountName;

  const NewAccountTypeScreen({
    Key? key,
    required this.keySubject,
    required this.accountName,
  }) : super(key: key);

  @override
  _NewAccountTypeScreenState createState() => _NewAccountTypeScreenState();
}

class _NewAccountTypeScreenState extends State<NewAccountTypeScreen> {
  final selectedWalletType = ValueNotifier<WalletType?>(null);
  late final AccountCreationBloc accountCreationBloc;

  @override
  void initState() {
    super.initState();
    accountCreationBloc = getIt.get<AccountCreationBloc>(param1: widget.keySubject);
  }

  @override
  void dispose() {
    selectedWalletType.dispose();
    accountCreationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WelcomeScaffold(
        onScaffoldTap: FocusScope.of(context).unfocus,
        headline: 'Select wallet type',
        body: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: buildBody(),
        ),
      );

  Widget buildBody() => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
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
      walletType: walletType,
    ));

    if (context.router.root.current.name == MainFlowRoute.name) {
      context.router.navigate(const WalletFlowRoute());
    }
  }
}
