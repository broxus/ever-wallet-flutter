import 'dart:async';

import 'package:crystal/domain/blocs/account/account_assets_bloc.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/models/token_contract_asset.dart';
import '../../../../../injection.dart';
import '../../../../design/design.dart';
import 'selection_asset_holder.dart';

class AssetsLayout extends StatefulWidget {
  final ScrollController controller;
  final String address;
  final void Function(List<TokenContractAsset> added, List<TokenContractAsset> removed) onSave;

  const AssetsLayout({
    Key? key,
    required this.controller,
    required this.address,
    required this.onSave,
  }) : super(key: key);

  @override
  _AssetsLayoutState createState() => _AssetsLayoutState();
}

class _AssetsLayoutState extends State<AssetsLayout> {
  final accountAssetsBloc = getIt.get<AccountAssetsBloc>();
  final selected = ValueNotifier<List<TokenContractAsset>>([]);
  final filtered = ValueNotifier<List<TokenContractAsset>>([]);
  late final StreamSubscription accountAssetsErrorsSubscription;

  @override
  void initState() {
    super.initState();
    accountAssetsErrorsSubscription =
        accountAssetsBloc.errorsStream.listen((event) => showErrorCrystalFlushbar(context, message: event));
    accountAssetsBloc.add(AccountAssetsEvent.load(widget.address));
  }

  @override
  void didUpdateWidget(covariant AssetsLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      accountAssetsBloc.add(AccountAssetsEvent.load(widget.address));
    }
  }

  @override
  void dispose() {
    accountAssetsBloc.close();
    selected.dispose();
    accountAssetsErrorsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AccountAssetsBloc, AccountAssetsState>(
        bloc: accountAssetsBloc,
        listener: (context, state) {
          selected.value = [...state.added];
          filtered.value = [...state.added, ...state.available];
        },
        builder: (context, state) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CrystalDivider(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 36,
                child: CrystalTextFormField(
                  onChanged: (value) {
                    final text = value.toLowerCase().trim();
                    filtered.value = [...state.added, ...state.available]
                        .where((e) => e.name.toLowerCase().contains(text) || e.symbol.toLowerCase().contains(text))
                        .toList();
                  },
                  backgroundColor: CrystalColor.whitelight,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  inputAction: TextInputAction.done,
                  border: InputBorder.none,
                  hintText: LocaleKeys.add_assets_modal_search_layout_hint.tr(),
                ),
              ),
            ),
            Flexible(
              child: ValueListenableBuilder<List<TokenContractAsset>>(
                valueListenable: filtered,
                builder: (context, filteredValue, child) => ValueListenableBuilder<List<TokenContractAsset>>(
                  valueListenable: selected,
                  builder: (context, value, child) => FadingEdgeScrollView.fromScrollView(
                    child: ListView.separated(
                      controller: widget.controller,
                      itemCount: filteredValue.length,
                      itemBuilder: (context, index) {
                        final asset = filteredValue[index];

                        return SelectionAssetHolder(
                          key: ValueKey(asset.address),
                          onTap: () {
                            final assets = [...selected.value];

                            if (value.contains(asset)) {
                              assets.remove(asset);
                            } else {
                              assets.add(asset);
                            }

                            selected.value = assets;
                          },
                          asset: filteredValue[index],
                          isSelected: value.contains(asset),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(thickness: 1, height: 1),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder<List<TokenContractAsset>>(
                valueListenable: selected,
                builder: (context, value, child) => CrystalButton(
                  text: LocaleKeys.actions_save.tr(),
                  enabled: !listEquals(value, state.added),
                  onTap: () {
                    context.router.pop();
                    widget.onSave(
                      value.where((e) => !state.added.contains(e)).toList(),
                      state.added.where((e) => !value.contains(e)).toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
}
