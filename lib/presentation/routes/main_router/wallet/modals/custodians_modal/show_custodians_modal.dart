import 'package:flutter/material.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'custodians_modal.dart';

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
