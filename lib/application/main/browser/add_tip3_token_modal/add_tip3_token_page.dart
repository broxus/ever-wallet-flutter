import 'package:ever_wallet/application/common/general/button/primary_elevated_button.dart';
import 'package:ever_wallet/application/common/widgets/custom_outlined_button.dart';
import 'package:ever_wallet/application/common/widgets/modal_header.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card.dart';
import 'package:ever_wallet/application/common/widgets/sectioned_card_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class AddTip3TokenPage extends StatefulWidget {
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

class _RequestPermissionsModalState extends State<AddTip3TokenPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ModalHeader(
                  text: AppLocalizations.of(context)!.add_asset,
                  onCloseButtonPressed: Navigator.of(widget.modalContext).pop,
                ),
                const Gap(16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: card(),
                  ),
                ),
                const Gap(16),
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
        title: AppLocalizations.of(context)!.origin,
        subtitle: widget.origin,
        isSelectable: true,
      );

  Widget account() => SectionedCardSection(
        title: AppLocalizations.of(context)!.account,
        subtitle: widget.account,
        isSelectable: true,
      );

  Widget version() => SectionedCardSection(
        title: AppLocalizations.of(context)!.version,
        subtitle: describeEnum(widget.details.version),
        isSelectable: true,
      );

  Widget name() => SectionedCardSection(
        title: AppLocalizations.of(context)!.name,
        subtitle: widget.details.name,
        isSelectable: true,
      );

  Widget symbol() => SectionedCardSection(
        title: AppLocalizations.of(context)!.symbol,
        subtitle: widget.details.symbol,
        isSelectable: true,
      );

  Widget decimals() => SectionedCardSection(
        title: AppLocalizations.of(context)!.decimals,
        subtitle: widget.details.decimals.toString(),
        isSelectable: true,
      );

  Widget ownerAddress() => SectionedCardSection(
        title: AppLocalizations.of(context)!.owner_address,
        subtitle: widget.details.ownerAddress,
        isSelectable: true,
      );

  Widget totalSupply() => SectionedCardSection(
        title: AppLocalizations.of(context)!.total_supply,
        subtitle: widget.details.totalSupply,
        isSelectable: true,
      );

  Widget buttons() => Row(
        children: [
          Expanded(
            child: rejectButton(),
          ),
          const Gap(16),
          Expanded(
            flex: 2,
            child: submitButton(),
          ),
        ],
      );

  Widget rejectButton() => CustomOutlinedButton(
        onPressed: () => Navigator.of(widget.modalContext).pop(),
        text: AppLocalizations.of(context)!.reject,
      );

  Widget submitButton() => PrimaryElevatedButton(
        onPressed: () => Navigator.of(widget.modalContext).pop(true),
        text: AppLocalizations.of(context)!.submit,
      );
}
