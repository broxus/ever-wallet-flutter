import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../design/design.dart';
import '../../../design/utils.dart';
import '../../../design/widget/crystal_bottom_sheet.dart';

class AccountSelection extends StatefulWidget {
  final List<AssetsList> accounts;
  final void Function(String) onTap;

  const AccountSelection._({
    Key? key,
    required this.accounts,
    required this.onTap,
  }) : super(key: key);

  static Future<void> open({
    required BuildContext context,
    required List<AssetsList> accounts,
    required void Function(String) onTap,
  }) =>
      showCrystalBottomSheet(
        context,
        expand: false,
        barrierColor: CrystalColor.modalBackground.withOpacity(0.7),
        title: 'Select account',
        body: AccountSelection._(
          accounts: accounts,
          onTap: onTap,
        ),
      );

  @override
  _AccountSelectionState createState() => _AccountSelectionState();
}

class _AccountSelectionState extends State<AccountSelection> {
  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: ListView.builder(
          physics: const ClampingScrollPhysics(),
          itemCount: widget.accounts.length,
          shrinkWrap: true,
          itemBuilder: (context, index) => ListTile(
            leading: SizedBox.square(
              dimension: 32,
              child: getGravatarIcon(widget.accounts[index].address.hashCode),
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
              widget.accounts[index].address.elipseAddress(),
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
        ),
      );
}
