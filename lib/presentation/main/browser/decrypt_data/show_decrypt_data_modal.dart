import 'package:flutter/material.dart';

import '../../../common/widgets/show_platform_modal_bottom_sheet.dart';
import 'decrypt_data_page.dart';

Future<String?> showDecryptDataModal({
  required BuildContext context,
  required String origin,
  required String publicKey,
  required String sourcePublicKey,
}) =>
    showPlatformModalBottomSheet<String>(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => DecryptDataPage(
            modalContext: context,
            origin: origin,
            publicKey: publicKey,
            sourcePublicKey: sourcePublicKey,
          ),
        ),
      ),
    );
