import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../domain/blocs/public_keys_labels_bloc.dart';
import '../../../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../../../injection.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/custom_popup_menu.dart';
import '../../../../../design/widgets/modal_header.dart';
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
  final infoBloc = getIt.get<TonWalletInfoBloc>();
  final publicKeysLabelsBloc = getIt.get<PublicKeysLabelsBloc>();

  @override
  void initState() {
    super.initState();
    infoBloc.add(TonWalletInfoEvent.load(widget.address));
  }

  @override
  void didUpdateWidget(covariant CustodiansModalBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      infoBloc.add(TonWalletInfoEvent.load(widget.address));
    }
  }

  @override
  void dispose() {
    super.dispose();
    infoBloc.close();
    publicKeysLabelsBloc.close();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<PublicKeysLabelsBloc, Map<String, String>>(
        builder: (context, publicKeysLabelsState) => BlocBuilder<TonWalletInfoBloc, TonWalletInfo?>(
          bloc: infoBloc,
          builder: (context, infoState) {
            final custodians = infoState?.custodians?.map((e) => Tuple2(publicKeysLabelsState[e], e)).toList() ?? [];

            return SizedBox(
              height: MediaQuery.of(context).size.longestSide / 1.75,
              child: Material(
                color: Colors.white,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const ModalHeader(
                          text: 'Custodians',
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
        ),
      );

  Widget list(List<Tuple2<String?, String>> custodians) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => custodians
            .map(
              (e) => item(
                title: e.item1 ?? 'Custodian ${index + 1}',
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
          Tuple2(
            'Edit',
            () => showEditCustodianLabelDialog(
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
