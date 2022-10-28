import 'package:collection/collection.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/unfocusing_gesture_detector.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class AddNewAccountTypePage extends StatefulWidget {
  final BuildContext modalContext;
  final String publicKey;
  final String? name;

  const AddNewAccountTypePage({
    super.key,
    required this.modalContext,
    required this.publicKey,
    this.name,
  });

  @override
  _NewSelectWalletTypePageState createState() => _NewSelectWalletTypePageState();
}

class _NewSelectWalletTypePageState extends State<AddNewAccountTypePage> {
  final optionNotifier = ValueNotifier<WalletType?>(null);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    optionNotifier.value = context
        .read<AccountsRepository>()
        .accountCreationOptions(widget.publicKey)
        .item2
        .firstOrNull;
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
            leading: CustomBackButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).maybePop();
                } else {
                  Navigator.of(widget.modalContext).maybePop();
                }
              },
            ),
            title: Text(
              context.localization.new_account_type,
              style: StylesRes.header3Text.copyWith(color: ColorsRes.black),
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
              const Gap(16),
              submitButton(),
            ],
          ),
        ),
      );

  Widget list() => AsyncValueStreamProvider<Tuple2<List<WalletType>, List<WalletType>>>(
        create: (context) =>
            context.read<AccountsRepository>().accountCreationOptionsStream(widget.publicKey),
        builder: (context, child) {
          final options =
              context.watch<AsyncValue<Tuple2<List<WalletType>, List<WalletType>>>>().maybeWhen(
                    ready: (value) => value,
                    orElse: () => null,
                  );

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
          title: Text(
            '${list[index].name}${list[index] == kDefaultWalletType ? ' (default)' : ""}',
          ),
        ),
      );

  Widget submitButton() => ValueListenableBuilder<WalletType?>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => PrimaryElevatedButton(
          onPressed: value != null ? () => onPressed(value) : null,
          text: context.localization.confirm,
        ),
      );

  Future<void> onPressed(WalletType value) async {
    await context.read<AccountsRepository>().addAccount(
          name: widget.name ?? value.name,
          publicKey: widget.publicKey,
          walletType: value,
          workchain: kDefaultWorkchain,
        );

    if (!mounted) return;

    Navigator.of(widget.modalContext).pop();
  }
}
