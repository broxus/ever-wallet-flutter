import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/general/button/primary_icon_button.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/default_list_tile.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/common/general/field/check_mark_widget.dart';
import 'package:ever_wallet/application/common/widgets/crystal_shimmer.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/select_derive_keys/select_derive_keys_cubit.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/extensions/iterable_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<void> showSelectDeriveKeysSheet({
  required BuildContext context,
  required KeyStoreEntry seed,
  required String password,
}) {
  return showEWBottomSheet(
    context,
    title: context.localization.select_keys_you_need,
    body: (_) => SelectDeriveKeysSheet(
      seed: seed,
      password: password,
    ),
  );
}

class SelectDeriveKeysSheet extends StatefulWidget {
  final KeyStoreEntry seed;
  final String password;

  const SelectDeriveKeysSheet({
    required this.seed,
    required this.password,
    super.key,
  });

  @override
  State<SelectDeriveKeysSheet> createState() => _SelectDeriveKeysSheetState();
}

class _SelectDeriveKeysSheetState extends State<SelectDeriveKeysSheet> {
  late SelectDeriveKeysCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = SelectDeriveKeysCubit(
      widget.seed,
      widget.password,
      context.read<Keystore>(),
      context.read<KeysRepository>(),
      () {
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        BlocBuilder<SelectDeriveKeysCubit, SelectDeriveKeysCubitState>(
          bloc: cubit,
          builder: (context, state) {
            return state.when(
              init: () => _loadingWidget(),
              display: (keys, selected, initial, page) =>
                  _displayWidget(keys, selected, initial, page),
              creating: (keys, selected, initial, page) =>
                  _displayWidget(keys, selected, initial, page, isLoading: true),
            );
          },
        ),
      ],
    );
  }

  Widget _accountItem(
    String accountAddress,
    int index, {
    required bool isSelected,
    required bool canChange,
  }) {
    return EWListTile(
      height: 55,
      onPressed: canChange ? () => cubit.toggleAddress(accountAddress) : null,
      contentPadding: EdgeInsets.zero,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckMarkWidget(
            isChecked: isSelected,
            color: canChange
                ? (isSelected ? ColorsRes.darkBlue : ColorsRes.grey3)
                : ColorsRes.lightBlue,
            fill: isSelected,
            checkMarkColor: ColorsRes.white,
          ),
          const SizedBox(width: 16),
          Text(
            '$index',
            style: StylesRes.basicText.copyWith(color: ColorsRes.grey),
          ),
        ],
      ),
      titleWidget: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Assets.images.account.svg(),
          ),
          Expanded(
            child: Text(
              accountAddress.ellipseAddress(),
              style: StylesRes.basicText.copyWith(color: ColorsRes.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingWidget() {
    return Column(
      children: [
        Row(
          children: const [
            CrystalShimmer(height: 20, width: 50),
            Spacer(),
            CrystalShimmer(height: 32, width: 32),
            SizedBox(width: 8),
            CrystalShimmer(height: 32, width: 32),
          ],
        ),
        const DefaultDivider(),
        ...List<Widget>.generate(
          5,
          (_) => const CrystalShimmer(height: 50, width: double.infinity),
        ).separated(const DefaultDivider()),
        const SizedBox(height: 40),
        PrimaryElevatedButton(onPressed: null, text: context.localization.select),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _displayWidget(
    List<String> keys,
    List<String> selected,
    List<String> initial,
    int page, {
    bool isLoading = false,
  }) {
    const count = SelectDeriveKeysCubit.countPerPage;
    final start = page * count;
    final end = start + count > keys.length ? keys.length : start + count;
    final sub = keys.sublist(start, end);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.localization.keys_count_of(selected.length + initial.length, keys.length),
                  style: StylesRes.medium14Caption.copyWith(color: ColorsRes.grey),
                ),
              ),
              PrimaryIconButton(
                outerPadding: EdgeInsets.zero,
                innerPadding: const EdgeInsets.all(6),
                icon: const Icon(Icons.keyboard_arrow_left_sharp, color: ColorsRes.darkBlue),
                onPressed: cubit.canPrevPage ? () => cubit.movePage(-1) : null,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorsRes.darkBlue.withOpacity(0.2)),
                ),
              ),
              const SizedBox(width: 8),
              PrimaryIconButton(
                outerPadding: EdgeInsets.zero,
                innerPadding: const EdgeInsets.all(6),
                icon: const Icon(Icons.keyboard_arrow_right_sharp, color: ColorsRes.darkBlue),
                onPressed: cubit.canNextPage ? () => cubit.movePage(1) : null,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorsRes.darkBlue.withOpacity(0.2)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const DefaultDivider(),
        ...sub.mapIndex((e, index) {
          final isInitial = initial.contains(e);
          final isSelected = selected.contains(e);
          return _accountItem(
            e,
            start + index + 1,
            isSelected: isInitial || isSelected,
            canChange: !isInitial,
          );
        }).separated(const DefaultDivider()),
        const SizedBox(height: 40),
        PrimaryElevatedButton(
          onPressed: isLoading ? null : () => cubit.selectAll(),
          text: context.localization.select,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
