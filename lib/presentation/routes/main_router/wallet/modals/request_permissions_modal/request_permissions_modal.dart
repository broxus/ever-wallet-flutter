import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../domain/blocs/account/accounts_provider.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/custom_elevated_button.dart';
import '../../../../../design/widgets/custom_outlined_button.dart';
import '../../../../../design/widgets/modal_header.dart';
import '../../../../../design/widgets/sectioned_card.dart';
import '../../../../../design/widgets/sectioned_card_section.dart';

class RequestPermissionsModalBody extends StatefulWidget {
  final String origin;
  final List<Permission> permissions;
  final String address;
  final String publicKey;

  const RequestPermissionsModalBody({
    Key? key,
    required this.origin,
    required this.permissions,
    required this.address,
    required this.publicKey,
  }) : super(key: key);

  @override
  State<RequestPermissionsModalBody> createState() => _RequestPermissionsModalBodyState();
}

class _RequestPermissionsModalBodyState extends State<RequestPermissionsModalBody> {
  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    ModalHeader(
                      text: 'Grant permissions',
                      onCloseButtonPressed: Navigator.of(context).pop,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: ModalScrollController.of(context),
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            card(),
                            const SizedBox(height: 64),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buttons(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget card() => SectionedCard(
        sections: [
          origin(),
          permissions(),
          address(),
          publicKey(),
        ],
      );

  Widget origin() => SectionedCardSection(
        title: 'Origin',
        subtitle: widget.origin,
        isSelectable: true,
      );

  Widget permissions() => SectionedCardSection(
        title: 'Requested permissions',
        subtitle: widget.permissions.map((e) => describeEnum(e).capitalize).join(', '),
        isSelectable: true,
      );

  Widget address() => SectionedCardSection(
        title: 'Account address',
        subtitle: widget.address,
        isSelectable: true,
      );

  Widget publicKey() => SectionedCardSection(
        title: 'Account public key',
        subtitle: widget.publicKey,
        isSelectable: true,
      );

  Widget buttons() => Row(
        children: [
          Expanded(
            child: rejectButton(),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: submitButton(),
          ),
        ],
      );

  Widget rejectButton() => CustomOutlinedButton(
        onPressed: () => Navigator.of(context).pop(null),
        text: 'Deny',
      );

  Widget submitButton() => Consumer(
        builder: (context, ref, child) => CustomElevatedButton(
          onPressed: () => onSubmitPressed(read: ref.read, publicKey: widget.publicKey),
          text: 'Allow',
        ),
      );

  Future<void> onSubmitPressed({
    required Reader read,
    required String publicKey,
  }) async {
    var permissions = const Permissions();

    final accounts = await read(accountsProvider.future);

    final walletType = accounts.firstWhere((e) => e.address == widget.address).tonWallet.contract;

    for (final permission in widget.permissions) {
      switch (permission) {
        case Permission.tonClient:
          permissions = permissions.copyWith(tonClient: true);
          break;
        case Permission.accountInteraction:
          permissions = permissions.copyWith(
            accountInteraction: AccountInteraction(
              address: widget.address,
              publicKey: widget.publicKey,
              contractType: walletType.toWalletType(),
            ),
          );
          break;
      }
    }

    if (!mounted) return;

    Navigator.of(context).pop(permissions);
  }
}
