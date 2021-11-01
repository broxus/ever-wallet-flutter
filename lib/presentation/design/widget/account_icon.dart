import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class AccountIcon extends StatefulWidget {
  final String address;

  const AccountIcon({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  _AccountIconState createState() => _AccountIconState();
}

class _AccountIconState extends State<AccountIcon> {
  late final String hash;

  @override
  void initState() {
    super.initState();
    hash = md5.convert(utf8.encode(widget.address)).toString();
  }

  @override
  Widget build(BuildContext context) => ClipOval(
        child: Image.network('https://www.gravatar.com/avatar/$hash?s=80&d=identicon&r=G'),
      );
}
