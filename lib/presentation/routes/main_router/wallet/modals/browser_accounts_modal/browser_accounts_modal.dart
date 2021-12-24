import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../design/design.dart';
import '../../../../../design/widgets/address_generated_icon.dart';
import '../../../../../design/widgets/modal_header.dart';

class BrowserAccountsModalBody extends StatefulWidget {
  final List<AssetsList> accounts;
  final void Function(String) onTap;

  const BrowserAccountsModalBody({
    Key? key,
    required this.accounts,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BrowserAccountsModalBody> createState() => _BrowserAccountsModalBodyState();
}

class _BrowserAccountsModalBodyState extends State<BrowserAccountsModalBody> {
  @override
  Widget build(BuildContext context) => SizedBox(
        height: MediaQuery.of(context).size.longestSide / 1.75,
        child: Material(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const ModalHeader(
                    text: 'Select account',
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: list(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget list() => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => ListTile(
          leading: SizedBox.square(
            dimension: 32,
            child: AddressGeneratedIcon(
              address: widget.accounts[index].address,
            ),
          ),
          title: Text(
            widget.accounts[index].name,
            style: const TextStyle(
              fontSize: 16,
              color: CrystalColor.fontDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            widget.accounts[index].address.ellipseAddress(),
            style: const TextStyle(
              fontSize: 16,
              color: CrystalColor.fontDark,
            ),
          ),
          onTap: () {
            context.router.pop();
            widget.onTap(widget.accounts[index].address);
          },
        ),
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
        ),
        itemCount: widget.accounts.length,
      );
}
