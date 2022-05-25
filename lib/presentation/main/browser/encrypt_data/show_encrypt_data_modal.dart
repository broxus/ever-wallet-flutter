import 'package:flutter/material.dart';

import '../../../common/widgets/show_platform_modal_bottom_sheet.dart';
import 'encrypt_data_page.dart';

Future<String?> showEncryptDataModal({
  required BuildContext context,
  required String origin,
  required String publicKey,
  required String data,
}) =>
    showPlatformModalBottomSheet<String>(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => EncryptDataPage(
            modalContext: context,
            origin: origin,
            publicKey: publicKey,
            data: data,
          ),
        ),
      ),
    );
