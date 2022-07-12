import 'package:ever_wallet/application/common/widgets/show_platform_modal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/wallet/modals/deploy_wallet_flow/prepare_deploy_page.dart';
import 'package:flutter/material.dart';

Future<void> startDeployWalletFlow({
  required BuildContext context,
  required String address,
  required String publicKey,
}) =>
    showPlatformModalBottomSheet(
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
