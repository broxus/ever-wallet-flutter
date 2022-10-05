import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/custom_popup_item.dart';
import 'package:ever_wallet/application/common/widgets/custom_popup_menu.dart';
import 'package:ever_wallet/application/common/widgets/modal_header.dart';
import 'package:ever_wallet/application/main/wallet/modals/custodians_modal/edit_custodian_label_dialog.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CustodiansModalBody extends StatefulWidget {
  final String address;

  const CustodiansModalBody({
    super.key,
    required this.address,
  });

  @override
  State<CustodiansModalBody> createState() => _CustodiansModalBodyState();
}

class _CustodiansModalBodyState extends State<CustodiansModalBody> {
  @override
  Widget build(BuildContext context) => AsyncValueStreamProvider<Map<String, String>>(
        create: (context) => context.read<KeysRepository>().labelsStream,
        builder: (context, child) {
          final publicKeysLabels = context.watch<AsyncValue<Map<String, String>>>().maybeWhen(
                ready: (value) => value,
                orElse: () => <String, String>{},
              );

          return AsyncValueStreamProvider<List<String>?>(
            create: (context) =>
                context.read<TonWalletsRepository>().custodiansStream(widget.address),
            builder: (context, child) {
              final custodians = context
                      .watch<AsyncValue<List<String>?>>()
                      .maybeWhen(
                        ready: (value) => value,
                        orElse: () => null,
                      )
                      ?.map((e) {
                    final title = publicKeysLabels[e] ?? e.ellipsePublicKey();

                    return Tuple2(title, e);
                  }).toList() ??
                  [];

              return SizedBox(
                height: MediaQuery.of(context).size.longestSide / 1.75,
                child: Material(
                  color: Colors.white,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ModalHeader(
                            text: AppLocalizations.of(context)!.custodians,
                          ),
                          const Gap(16),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: list(custodians),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

  Widget list(List<Tuple2<String?, String>> custodians) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => custodians
            .map(
              (e) => item(
                title: e.item1 ?? AppLocalizations.of(context)!.custodian_n('${index + 1}'),
                publicKey: e.item2,
              ),
            )
            .toList()[index],
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
        ),
        itemCount: custodians.length,
      );

  Widget item({
    required String title,
    required String publicKey,
  }) =>
      ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CrystalColor.accent,
          ),
        ),
        subtitle: Text(
          publicKey.ellipsePublicKey(),
        ),
        trailing: more(publicKey),
      );

  Widget more(String publicKey) => CustomPopupMenu(
        items: [
          CustomPopupItem(
            title: Text(
              AppLocalizations.of(context)!.edit,
              style: const TextStyle(fontSize: 16),
            ),
            onTap: () => showEditCustodianLabelDialog(
              context: context,
              publicKey: publicKey,
            ),
          ),
        ],
        icon: const Icon(
          Icons.more_vert,
          color: Colors.grey,
        ),
      );
}
