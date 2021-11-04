import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../design/design.dart';
import '../../../design/widget/crystal_bottom_sheet.dart';

class RequestPermissionsBody extends StatefulWidget {
  final String origin;
  final List<Permission> permissions;
  final String address;
  final String publicKey;

  const RequestPermissionsBody._({
    Key? key,
    required this.origin,
    required this.permissions,
    required this.address,
    required this.publicKey,
  }) : super(key: key);

  static Future<bool?> open({
    required BuildContext context,
    required String origin,
    required List<Permission> permissions,
    required String address,
    required String publicKey,
  }) =>
      showCrystalBottomSheet<bool>(
        context,
        expand: false,
        barrierColor: CrystalColor.modalBackground.withOpacity(0.7),
        title: 'Grant permissions',
        body: RequestPermissionsBody._(
          origin: origin,
          permissions: permissions,
          address: address,
          publicKey: publicKey,
        ),
      );

  @override
  _RequestPermissionsBodyState createState() => _RequestPermissionsBodyState();
}

class _RequestPermissionsBodyState extends State<RequestPermissionsBody> {
  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                color: CrystalColor.grayBackground,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildInfo(
                      title: "Origin",
                      value: widget.origin,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    buildInfo(
                      title: "Requested permissions",
                      value: widget.permissions.map((e) => describeEnum(e).capitalize).join(', '),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    buildInfo(
                      title: "Account address",
                      value: widget.address,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    buildInfo(
                      title: "Account public key",
                      value: widget.publicKey,
                    ),
                  ],
                ),
              ),
              buildButtons(
                onDenyTapped: () => Navigator.of(context).pop(false),
                onAllowTapped: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      );

  Widget buildInfo({
    required String title,
    required String value,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: CrystalColor.fontTitleSecondaryDark,
              fontSize: 16,
            ),
          ),
          const CrystalDivider(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: CrystalColor.fontDark,
            ),
          ),
        ],
      );

  Widget buildButtons({
    required VoidCallback onDenyTapped,
    required VoidCallback onAllowTapped,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CrystalButton(
              type: CrystalButtonType.outline,
              text: "Deny",
              onTap: onDenyTapped,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: CrystalButton(
              text: "Allow",
              onTap: onAllowTapped,
            ),
          ),
        ],
      );
}
