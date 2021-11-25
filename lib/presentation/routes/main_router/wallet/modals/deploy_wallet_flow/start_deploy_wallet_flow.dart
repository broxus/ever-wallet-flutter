import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'prepare_deploy_page.dart';

Future<void> startDeployWalletFlow({
  required BuildContext context,
  required String address,
  required String publicKey,
}) =>
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => Navigator(
        initialRoute: '/',
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => PrepareDeployPage(
            modalContext: context,
            address: address,
            publicKey: publicKey,
          ),
        ),
      ),
    );
