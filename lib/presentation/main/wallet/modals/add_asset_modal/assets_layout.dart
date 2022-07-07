import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../data/models/token_contract_asset.dart';
import '../../../../../../providers/account/account_assets_options_provider.dart';
import '../../../../common/general/button/primary_elevated_button.dart';
import '../../../../common/widgets/custom_text_form_field.dart';
import '../../../../common/widgets/text_field_clear_button.dart';
import '../../../../common/widgets/unfocusing_gesture_detector.dart';
import 'selection_asset_holder.dart';

class AssetsLayout extends StatefulWidget {
  final String address;
  final void Function(
    List<TokenContractAsset> added,
    List<TokenContractAsset> removed,
  ) onSave;

  const AssetsLayout({
    Key? key,
    required this.address,
    required this.onSave,
  }) : super(key: key);

  @override
  _AssetsLayoutState createState() => _AssetsLayoutState();
}

class _AssetsLayoutState extends State<AssetsLayout> {
  final controller = TextEditingController();
  final selectedNotifier = ValueNotifier<List<TokenContractAsset>>([]);
  final filteredNotifier = ValueNotifier<List<TokenContractAsset>>([]);

  @override
  void dispose() {
    controller.dispose();
    selectedNotifier.dispose();
    filteredNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final accountAssetsOptions = ref.watch(accountAssetsOptionsProvider(widget.address)).asData?.value;
          final added = accountAssetsOptions?.item1 ?? [];
          final available = accountAssetsOptions?.item2 ?? [];

          selectedNotifier.value = [...added];
          filteredNotifier.value = [...added, ...available];

          return UnfocusingGestureDetector(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: field(
                    added: added,
                    available: available,
                  ),
                ),
                Expanded(
                  child: list(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: submitButton(
                    added: added,
                    available: available,
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget field({
    required List<TokenContractAsset> added,
    required List<TokenContractAsset> available,
  }) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
        ),
        child: CustomTextFormField(
          name: AppLocalizations.of(context)!.search,
          controller: controller,
          autocorrect: false,
          enableSuggestions: false,
          hintText: AppLocalizations.of(context)!.enter_asset_name,
          suffixIcon: TextFieldClearButton(controller: controller),
          onChanged: (value) {
            final text = value?.toLowerCase().trim() ?? '';
            filteredNotifier.value = [...added, ...available]
                .where((e) => e.name.toLowerCase().contains(text) || e.symbol.toLowerCase().contains(text))
                .toList();
          },
          borderColor: Colors.transparent,
          errorBorderColor: Colors.transparent,
        ),
      );

  Widget list() => ValueListenableBuilder<List<TokenContractAsset>>(
        valueListenable: filteredNotifier,
        builder: (context, filteredValue, child) => ValueListenableBuilder<List<TokenContractAsset>>(
          valueListenable: selectedNotifier,
          builder: (context, value, child) => ListView.separated(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: filteredValue.length,
            itemBuilder: (context, index) {
              final asset = filteredValue[index];

              return SelectionAssetHolder(
                key: ValueKey(asset.address),
                onTap: () {
                  final assets = [...selectedNotifier.value];

                  if (value.contains(asset)) {
                    assets.remove(asset);
                  } else {
                    assets.add(asset);
                  }

                  selectedNotifier.value = assets;
                },
                asset: filteredValue[index],
                isSelected: value.contains(asset),
              );
            },
            separatorBuilder: (_, __) => const Divider(thickness: 1, height: 1),
          ),
        ),
      );

  Widget submitButton({
    required List<TokenContractAsset> added,
    required List<TokenContractAsset> available,
  }) =>
      ValueListenableBuilder<List<TokenContractAsset>>(
        valueListenable: selectedNotifier,
        builder: (context, value, child) => PrimaryElevatedButton(
          onPressed: !listEquals(value, added)
              ? () {
                  context.router.pop();
                  widget.onSave(
                    value.where((e) => !added.contains(e)).toList(),
                    added.where((e) => !value.contains(e)).toList(),
                  );
                }
              : null,
          text: AppLocalizations.of(context)!.save,
        ),
      );
}
