import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/blocs/account/account_creation_options_bloc.dart';
import '../../../../../../../../domain/blocs/key/keys_bloc.dart';
import '../../../../../../../../domain/constants/default_wallet_type.dart';
import '../../../../../../../../injection.dart';
import '../../../../design/design.dart';
import '../../../../design/utils.dart';
import '../../../../design/widgets/crystal_scaffold.dart';
import '../../../router.gr.dart';

class NewAccountTypePage extends StatefulWidget {
  @override
  _NewAccountTypePageState createState() => _NewAccountTypePageState();
}

class _NewAccountTypePageState extends State<NewAccountTypePage> {
  final selectedWalletType = ValueNotifier<WalletType?>(null);
  final accountCreationOptionsBloc = getIt.get<AccountCreationOptionsBloc>();

  @override
  void initState() {
    super.initState();

    final publicKey = context.read<KeysBloc>().state.currentKey?.publicKey;

    if (publicKey != null) {
      accountCreationOptionsBloc.add(AccountCreationOptionsEvent.load(publicKey));
    }
  }

  @override
  void dispose() {
    selectedWalletType.dispose();
    accountCreationOptionsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: CrystalScaffold(
          onScaffoldTap: FocusScope.of(context).unfocus,
          headline: 'Select wallet type',
          body: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: buildBody(),
          ),
        ),
      );

  Widget buildBody() => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Stack(
          children: [
            BlocConsumer<AccountCreationOptionsBloc, AccountCreationOptionsState>(
              bloc: accountCreationOptionsBloc,
              listener: (context, state) {
                selectedWalletType.value = state.available.firstOrNull;
              },
              builder: (context, state) => ListView.builder(
                itemCount: state.added.length + state.available.length,
                itemBuilder: (BuildContext context, int index) {
                  final list = [...state.added, ...state.available]..sort((a, b) => a.toInt().compareTo(b.toInt()));

                  return ValueListenableBuilder<WalletType?>(
                    valueListenable: selectedWalletType,
                    builder: (context, value, child) => Theme(
                      data: ThemeData(),
                      child: RadioListTile<WalletType>(
                        value: list[index],
                        groupValue: value,
                        onChanged:
                            !state.added.contains(list[index]) ? (value) => selectedWalletType.value = value : null,
                        activeColor: CrystalColor.accent,
                        title:
                            Text('${list[index].describe()}${list[index] == kDefaultWalletType ? ' (default)' : ""}'),
                      ),
                    ),
                  );
                },
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
    final publicKey = context.read<KeysBloc>().state.currentKey?.publicKey;

    if (publicKey != null) {
      context.router.push(NewAccountNameRoute(
        publicKey: publicKey,
        walletType: walletType,
      ));
    }
  }
}
