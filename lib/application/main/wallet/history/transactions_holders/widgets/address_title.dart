import 'package:ever_wallet/application/common/extensions.dart';
import 'package:flutter/material.dart';

class AddressTitle extends StatelessWidget {
  final String address;

  const AddressTitle({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Text(
        address.ellipseAddress(),
      );
}
