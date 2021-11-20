import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../design.dart';

class WordsGridWidget extends StatelessWidget {
  const WordsGridWidget(
    this.words, {
    this.columns = 2,
    this.animated = false,
  }) : _countInColumn = words.length / columns;

  final List<String> words;
  final int columns;
  final bool animated;
  final double _countInColumn;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          columns,
          (column) {
            final _words = wordWidgets(column: column);
            return Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _words.length,
                separatorBuilder: (_, __) => const CrystalDivider(height: 16),
                itemBuilder: (_, i) => animated
                    ? AnimatedAppearance(
                        delay: const Duration(milliseconds: 50) * (_countInColumn * column + i + 1),
                        offset: const Offset(1, 0),
                        child: _words[i],
                      )
                    : _words[i],
              ),
            );
          },
        ),
      );

  List<Widget> wordWidgets({required int column}) {
    final count = _countInColumn.ceil();
    return List.generate(
      words.length,
      (i) => Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${i + 1}.',
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                color: CrystalColor.fontDark,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              words[i],
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 16,
                color: CrystalColor.fontDark,
              ),
            ),
          ),
        ],
      ),
    ).skip(count * column).take(count).toList();
  }
}
