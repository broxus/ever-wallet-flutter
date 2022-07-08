import 'package:collection/collection.dart';
import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/custom_back_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/unfocusing_gesture_detector.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/repositories/accounts_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context
        .read<AccountsRepository>()
        .accountCreationOptions(widget.publicKey)
        .first
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
            title: Text(
              AppLocalizations.of(context)!.new_account_type,
              style: const TextStyle(
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
              const Gap(16),
              submitButton(),
            ],
          ),
        ),
      );

  Widget list() => StreamProvider<AsyncValue<Tuple2<List<WalletType>, List<WalletType>>>>(
        create: (context) => context
            .read<AccountsRepository>()
            .accountCreationOptions(widget.publicKey)
            .map((event) => AsyncValue.ready(event)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
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
            '${list[index].describe()}${list[index] == kDefaultWalletType ? ' (default)' : ""}',
          ),
        ),
      );

  Widget submitButton() => ValueListenableBuilder<WalletType?>(
        valueListenable: optionNotifier,
        builder: (context, value, child) => CustomElevatedButton(
          onPressed: value != null ? () => onPressed(value) : null,
          text: AppLocalizations.of(context)!.confirm,
        ),
      );

  Future<void> onPressed(WalletType value) async {
    await context.read<AccountsRepository>().addAccount(
          name: widget.name ?? value.describe(),
          publicKey: widget.publicKey,
          walletType: value,
        );

    if (!mounted) return;

    Navigator.of(widget.modalContext).pop();
  }
}
