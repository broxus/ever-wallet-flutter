import 'package:ever_wallet/application/common/extensions.dart';
import 'package:flutter/material.dart';

class AddressTitle extends StatelessWidget {
  final String address;

  const AddressTitle({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context) => Text(
        address.ellipseAddress(),
      );
}
