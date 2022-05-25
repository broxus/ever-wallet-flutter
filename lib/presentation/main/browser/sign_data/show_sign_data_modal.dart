import 'package:flutter/material.dart';

import '../../../common/widgets/show_platform_modal_bottom_sheet.dart';
import 'sign_data_page.dart';

Future<String?> showSignDataModal({
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
          builder: (_) => SignDataPage(
            modalContext: context,
            origin: origin,
            publicKey: publicKey,
            data: data,
          ),
        ),
      ),
    );
