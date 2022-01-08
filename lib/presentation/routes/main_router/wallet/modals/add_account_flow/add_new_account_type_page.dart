import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../data/repositories/accounts_repository.dart';
import '../../../../../../domain/blocs/account/account_creation_options_provider.dart';
import '../../../../../../injection.dart';
import '../../../../../design/default_wallet_type.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/custom_back_button.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/unfocusing_gesture_detector.dart';

class AddNewAccountTypePage extends ConsumerStatefulWidget {
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

class _NewSelectWalletTypePageState extends ConsumerState<AddNewAccountTypePage> {
  final optionNotifier = ValueNotifier<WalletType?>(null);

  @override
  void initState() {
    super.initState();
    ref
        .read(accountCreationOptionsProvider(widget.publicKey).future)
        .then((value) => optionNotifier.value = value.item2.firstOrNull);
  }

  @override
  void dispose() {
    optionNotifier.dispose();
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

  Widget list() => Consumer(
        builder: (context, ref, child) {
          final options = ref.watch(accountCreationOptionsProvider(widget.publicKey)).asData?.value;
          final added = options?.item1 ?? [];
          final available = options?.item2 ?? [];

          final list = [...added, ...available]..sort((a, b) => a.toInt().compareTo(b.toInt()));

          return ListView.builder(
            itemCount: list.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) => item(
              list: list,
              index: index,
              added: added,
              available: available,
            ),
          );
        },
      );

  Widget item({
    required List<WalletType> list,
    required int index,
    required List<WalletType> added,
    required List<WalletType> available,
  }) =>
      ValueListenableBuilder<WalletType?>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => RadioListTile<WalletType>(
          value: list[index],
          groupValue: value,
          onChanged: !added.contains(list[index]) ? (value) => optionNotifier.value = value : null,
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
