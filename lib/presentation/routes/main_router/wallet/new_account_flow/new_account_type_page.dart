import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../domain/blocs/account/account_creation_options_bloc.dart';
import '../../../../../domain/blocs/key/keys_bloc.dart';
import '../../../../../domain/constants/default_wallet_type.dart';
import '../../../../../injection.dart';
import '../../../../design/design.dart';
import '../../../../design/widgets/crystal_title.dart';
import '../../../../design/widgets/custom_back_button.dart';
import '../../../../design/widgets/custom_elevated_button.dart';
import '../../../router.gr.dart';

class NewAccountTypePage extends StatefulWidget {
  const NewAccountTypePage({
    Key? key,
  }) : super(key: key);

  @override
  State<NewAccountTypePage> createState() => _NewAccountTypePageState();
}

class _NewAccountTypePageState extends State<NewAccountTypePage> {
  final optionNotifier = ValueNotifier<WalletType?>(null);
  final bloc = getIt.get<AccountCreationOptionsBloc>();

  @override
  void initState() {
    super.initState();

    final publicKey = context.read<KeysBloc>().state.currentKey?.publicKey;

    if (publicKey != null) {
      bloc.add(AccountCreationOptionsEvent.load(publicKey));
    }
  }

  @override
  void dispose() {
    optionNotifier.dispose();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          appBar: AppBar(
            leading: CustomBackButton(
              onPressed: () => context.router.pop(),
            ),
          ),
          body: body(),
        ),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16) - const EdgeInsets.only(top: 16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    title(),
                    const SizedBox(height: 32),
                    list(),
                    const SizedBox(height: 16),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    submitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget list() => BlocConsumer<AccountCreationOptionsBloc, AccountCreationOptionsState>(
        bloc: bloc,
        listener: (context, state) => optionNotifier.value = state.available.firstOrNull,
        builder: (context, state) {
          final list = [...state.added, ...state.available]..sort((a, b) => a.toInt().compareTo(b.toInt()));

          return ListView.builder(
            itemCount: state.added.length + state.available.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) => item(
              list: list,
              index: index,
              state: state,
            ),
          );
        },
      );

  Widget item({
    required List<WalletType> list,
    required int index,
    required AccountCreationOptionsState state,
  }) =>
      ValueListenableBuilder<WalletType?>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => RadioListTile<WalletType>(
          value: list[index],
          groupValue: value,
          onChanged: !state.added.contains(list[index]) ? (value) => optionNotifier.value = value : null,
          activeColor: CrystalColor.accent,
          title: Text('${list[index].describe()}${list[index] == kDefaultWalletType ? ' (default)' : ""}'),
        ),
      );

  Widget title() => const CrystalTitle(
        text: 'Select wallet type',
      );

  Widget submitButton() => ValueListenableBuilder<WalletType?>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => CustomElevatedButton(
          onPressed: value != null ? () => onPressed(value) : null,
          text: 'Next',
        ),
      );

  void onPressed(WalletType walletType) {
    final publicKey = context.read<KeysBloc>().state.currentKey?.publicKey;

    if (publicKey != null) {
      context.router.push(
        NewAccountNameRoute(
          publicKey: publicKey,
          walletType: walletType,
        ),
      );
    }
  }
}
