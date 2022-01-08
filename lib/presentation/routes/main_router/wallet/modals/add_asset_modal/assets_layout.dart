import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../data/dtos/token_contract_asset_dto.dart';
import '../../../../../../domain/blocs/account/account_assets_options_provider.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/custom_text_form_field.dart';
import '../../../../../design/widgets/text_field_clear_button.dart';
import '../../../../../design/widgets/unfocusing_gesture_detector.dart';
import 'selection_asset_holder.dart';

class AssetsLayout extends StatefulWidget {
  final String address;
  final void Function(
    List<TokenContractAssetDto> added,
    List<TokenContractAssetDto> removed,
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
  final selectedNotifier = ValueNotifier<List<TokenContractAssetDto>>([]);
  final filteredNotifier = ValueNotifier<List<TokenContractAssetDto>>([]);

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

          selectedNotifier.value = [...added]..sort((a, b) => a.name.compareTo(b.name));
          filteredNotifier.value = [...added, ...available]..sort((a, b) => a.name.compareTo(b.name));

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
    required List<TokenContractAssetDto> added,
    required List<TokenContractAssetDto> available,
  }) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
        ),
        child: CustomTextFormField(
          name: 'search',
          controller: controller,
          autocorrect: false,
          enableSuggestions: false,
          hintText: LocaleKeys.add_assets_modal_search_layout_hint.tr(),
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

  Widget list() => ValueListenableBuilder<List<TokenContractAssetDto>>(
        valueListenable: filteredNotifier,
        builder: (context, filteredValue, child) => ValueListenableBuilder<List<TokenContractAssetDto>>(
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
    required List<TokenContractAssetDto> added,
    required List<TokenContractAssetDto> available,
  }) =>
      ValueListenableBuilder<List<TokenContractAssetDto>>(
        valueListenable: selectedNotifier,
        builder: (context, value, child) => CustomElevatedButton(
          onPressed: !listEquals(value, added)
              ? () {
                  context.router.pop();
                  widget.onSave(
                    value.where((e) => !added.contains(e)).toList(),
                    added.where((e) => !value.contains(e)).toList(),
                  );
                }
              : null,
          text: LocaleKeys.actions_save.tr(),
        ),
      );
}
