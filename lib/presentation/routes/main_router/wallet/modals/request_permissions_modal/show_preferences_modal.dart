import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../design/widgets/show_platform_modal_bottom_sheet.dart';
import 'request_permissions_modal.dart';

Future<Permissions?> showRequestPermissionsModal({
  required BuildContext context,
  required String origin,
  required List<Permission> permissions,
  required String address,
  required String publicKey,
}) =>
    showPlatformModalBottomSheet<Permissions>(
      context: context,
      builder: (context) => RequestPermissionsModalBody(
        origin: origin,
        permissions: permissions,
        address: address,
        publicKey: publicKey,
      ),
    );
