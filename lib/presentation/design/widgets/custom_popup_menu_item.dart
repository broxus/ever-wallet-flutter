import 'package:flutter/material.dart';

class CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  CustomPopupMenuItem({
    Key? key,
    required T value,
    required String data,
  }) : super(
          key: key,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          value: value,
          child: Text(
            data,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        );
}
