import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../data/repositories/accounts_repository.dart';
import '../../../../../../domain/blocs/account/account_creation_options_bloc.dart';
import '../../../../../../injection.dart';
import '../../../../../design/default_wallet_type.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/custom_back_button.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/unfocusing_gesture_detector.dart';

class AddNewAccountTypePage extends StatefulWidget {
  final BuildContext modalContext;
  final String publicKey;
  final String? name;

  const AddNewAccountTypePage({
    Key? key,
    required this.modalContext,
    required this.publicKey,
    this.name,
  }) : super(key: key);

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<AddNewAccountTypePage> {
  final optionNotifier = ValueNotifier<WalletType?>(null);
  final bloc = getIt.get<AccountCreationOptionsBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(AccountCreationOptionsEvent.load(widget.publicKey));
  }

  @override
  void dispose() {
    optionNotifier.dispose();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UnfocusingGestureDetector(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: const CustomBackButton(),
            title: const Text(
              'New account type',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          body: body(),
        ),
      );

  Widget body() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      list(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              submitButton(),
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

  Widget submitButton() => ValueListenableBuilder<WalletType?>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => CustomElevatedButton(
          onPressed: value != null ? () => onPressed(value) : null,
          text: 'Confirm',
        ),
      );

  Future<void> onPressed(WalletType value) async {
    await getIt.get<AccountsRepository>().addAccount(
          name: widget.name ?? value.describe(),
          publicKey: widget.publicKey,
          walletType: value,
        );

    if (!mounted) return;

    Navigator.of(widget.modalContext).pop();
  }
}
