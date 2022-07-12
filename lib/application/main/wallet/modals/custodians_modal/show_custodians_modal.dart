import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/custodians_modal/custodians_modal.dart';
import 'package:flutter/material.dart';

Future<void> showCustodiansModal({
  required BuildContext context,
  required String address,
}) =>
    showPlatformModalBottomSheet(
      context: context,
      builder: (context) => CustodiansModalBody(
        address: address,
      ),
    );
