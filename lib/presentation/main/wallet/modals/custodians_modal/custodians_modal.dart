import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../providers/key/public_keys_labels_provider.dart';
import '../../../../../../providers/ton_wallet/ton_wallet_info_provider.dart';
import '../../../../common/extensions.dart';
import '../../../../common/theme.dart';
import '../../../../common/widgets/custom_popup_item.dart';
import '../../../../common/widgets/custom_popup_menu.dart';
import '../../../../common/widgets/modal_header.dart';
import 'edit_custodian_label_dialog.dart';

class CustodiansModalBody extends StatefulWidget {
  final String address;

  const CustodiansModalBody({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<CustodiansModalBody> createState() => _CustodiansModalBodyState();
}

class _CustodiansModalBodyState extends State<CustodiansModalBody> {
  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final publicKeysLabels = ref.watch(publicKeysLabelsProvider).asData?.value ?? {};
          final tonWalletInfo = ref.watch(tonWalletInfoProvider(widget.address)).asData?.value;

          final custodians = tonWalletInfo?.custodians?.map((e) {
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
                      const SizedBox(height: 16),
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
