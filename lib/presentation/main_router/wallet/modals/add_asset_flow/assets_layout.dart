import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/models/token_contract_asset.dart';
import '../../../../design/design.dart';
import 'selection_asset_holder.dart';

class AssetsLayout extends StatefulWidget {
  final ScrollController controller;
  final List<TokenContractAsset> available;
  final List<TokenContractAsset> added;
  final void Function(List<TokenContractAsset>) onSave;

  const AssetsLayout({
    Key? key,
    required this.controller,
    required this.available,
    required this.added,
    required this.onSave,
  }) : super(key: key);

  @override
  _AssetsLayoutState createState() => _AssetsLayoutState();
}

class _AssetsLayoutState extends State<AssetsLayout> {
  final assets = ValueNotifier<List<TokenContractAsset>>([]);
  late final ValueNotifier<List<TokenContractAsset>> filtered;

  @override
  void initState() {
    super.initState();
    assets.value = widget.added;
    filtered = ValueNotifier<List<TokenContractAsset>>(widget.available);
  }

  @override
  void dispose() {
    assets.dispose();
    filtered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CrystalDivider(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 36,
              child: CrystalTextFormField(
                onChanged: (value) {
                  final text = value.toLowerCase();
                  filtered.value = widget.available.where((e) => e.name.toLowerCase().contains(text)).toList();
                },
                backgroundColor: CrystalColor.whitelight,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                border: InputBorder.none,
                hintText: LocaleKeys.add_assets_modal_search_layout_hint.tr(),
              ),
            ),
          ),
          Flexible(
            child: ValueListenableBuilder<List<TokenContractAsset>>(
              valueListenable: filtered,
              builder: (context, valueFiltered, child) => FadingEdgeScrollView.fromScrollView(
                child: ListView.separated(
                  controller: widget.controller,
                  itemCount: valueFiltered.length,
                  itemBuilder: (context, index) => ValueListenableBuilder<List<TokenContractAsset>>(
                    valueListenable: assets,
                    builder: (context, value, child) {
                      final asset = valueFiltered[index];

                      return SelectionAssetHolder(
                        onTap: () {
                          late final List<TokenContractAsset> newAssets;

                          if (assets.value.contains(asset)) {
                            newAssets = [...assets.value]..remove(asset);
                          } else {
                            newAssets = [...assets.value, asset];
                          }

                          assets.value = [...newAssets];
                        },
                        asset: valueFiltered[index],
                        isSelected: value.contains(asset),
                      );
                    },
                  ),
                  separatorBuilder: (_, __) => const Divider(thickness: 1, height: 1),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ValueListenableBuilder<List<TokenContractAsset>>(
              valueListenable: assets,
              builder: (context, value, child) => CrystalButton(
                text: LocaleKeys.actions_save.tr(),
                enabled: !listEquals(value, widget.added),
                onTap: () {
                  context.router.pop();
                  widget.onSave(value);
                },
              ),
            ),
          ),
        ],
      );
}
