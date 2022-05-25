import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../generated/codegen_loader.g.dart';
import '../../../common/widgets/custom_elevated_button.dart';
import '../../../common/widgets/custom_outlined_button.dart';
import '../../../common/widgets/modal_header.dart';
import '../../../common/widgets/sectioned_card.dart';
import '../../../common/widgets/sectioned_card_section.dart';

class AddTip3TokenPage extends ConsumerStatefulWidget {
  final BuildContext modalContext;
  final String origin;
  final String account;
  final RootTokenContractDetails details;

  const AddTip3TokenPage({
    Key? key,
    required this.modalContext,
    required this.origin,
    required this.account,
    required this.details,
  }) : super(key: key);

  @override
  _RequestPermissionsModalState createState() => _RequestPermissionsModalState();
}

class _RequestPermissionsModalState extends ConsumerState<AddTip3TokenPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ModalHeader(
                  text: LocaleKeys.add_asset.tr(),
                  onCloseButtonPressed: Navigator.of(widget.modalContext).pop,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: card(),
                  ),
                ),
                const SizedBox(height: 16),
                buttons(),
              ],
            ),
          ),
        ),
      );

  Widget card() => SectionedCard(
        sections: [
          origin(),
          account(),
          version(),
          name(),
          symbol(),
          decimals(),
          ownerAddress(),
          totalSupply(),
        ],
      );

  Widget origin() => SectionedCardSection(
        title: LocaleKeys.origin.tr(),
        subtitle: widget.origin,
        isSelectable: true,
      );

  Widget account() => SectionedCardSection(
        title: LocaleKeys.account.tr(),
        subtitle: widget.account,
        isSelectable: true,
      );

  Widget version() => SectionedCardSection(
        title: LocaleKeys.version.tr(),
        subtitle: describeEnum(widget.details.version),
        isSelectable: true,
      );

  Widget name() => SectionedCardSection(
        title: LocaleKeys.name.tr(),
        subtitle: widget.details.name,
        isSelectable: true,
      );

  Widget symbol() => SectionedCardSection(
        title: LocaleKeys.symbol.tr(),
        subtitle: widget.details.symbol,
        isSelectable: true,
      );

  Widget decimals() => SectionedCardSection(
        title: LocaleKeys.decimals.tr(),
        subtitle: widget.details.decimals.toString(),
        isSelectable: true,
      );

  Widget ownerAddress() => SectionedCardSection(
        title: LocaleKeys.owner_address.tr(),
        subtitle: widget.details.ownerAddress,
        isSelectable: true,
      );

  Widget totalSupply() => SectionedCardSection(
        title: LocaleKeys.total_supply.tr(),
        subtitle: widget.details.totalSupply,
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
        onPressed: () => Navigator.of(widget.modalContext).pop(),
        text: LocaleKeys.reject.tr(),
      );

  Widget submitButton() => CustomElevatedButton(
        onPressed: () => Navigator.of(widget.modalContext).pop(true),
        text: LocaleKeys.submit.tr(),
      );
}
