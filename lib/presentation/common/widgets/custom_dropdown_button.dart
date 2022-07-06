import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  final List<Tuple2<T, String>> items;
  final T? value;
  final void Function(T?) onChanged;

  const CustomDropdownButton({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
        ),
        child: DropdownButton2<T>(
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e.item1,
                  child: Text(
                    e.item2,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              )
              .toList(),
          value: value,
          onChanged: onChanged,
          style: const TextStyle(
            color: Colors.black,
          ),
          underline: const SizedBox(),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.black,
          ),
          isExpanded: true,
          offset: Offset.zero,
          dropdownPadding: EdgeInsets.zero,
          buttonDecoration: const BoxDecoration(
            color: Colors.white,
          ),
        ),
      );
}
