import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/browser/sign_data/sign_data_page.dart';
import 'package:flutter/material.dart';

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
