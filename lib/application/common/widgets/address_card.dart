import 'package:ever_wallet/application/common/widgets/selectable_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AddressCard extends StatefulWidget {
  final String address;

  const AddressCard({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) => Row(
        children: [
          QrImage(
            size: MediaQuery.of(context).size.shortestSide / 2.5,
            data: widget.address,
          ),
          const Gap(16),
          Expanded(
            child: SelectableField(
              value: widget.address,
              child: Text(
                widget.address,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      );
}
