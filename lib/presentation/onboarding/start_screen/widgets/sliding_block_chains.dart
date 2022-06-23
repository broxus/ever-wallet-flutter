import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../util/extensions/iterable_extensions.dart';

const _paddingBetweenRows = 16.0;

/// Panel of sliding block chains on main screen
class SlidingBlockChains extends StatefulWidget {
  const SlidingBlockChains({Key? key}) : super(key: key);

  @override
  State<SlidingBlockChains> createState() => _SlidingBlockChainsState();
}

class _SlidingBlockChainsState extends State<SlidingBlockChains> {
  late Timer timer;
  final controllers = List.generate(3, (_) => ScrollController());
  final images = <List<Color>>[];

  @override
  void initState() {
    super.initState();

    /// TODO: replace colors with images
    images.addAll(
      List.generate(
        3,
        (index) => List.generate(
          10,
          (index) => Colors.primaries[Random().nextInt(Colors.primaries.length)],
        ),
      ),
    );

    timer = Timer.periodic(const Duration(milliseconds: 30), (timer) => _scrollLists());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _scrollLists() => controllers.forEach((c) => c.jumpTo(c.offset + 1));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final partSize = (constraints.maxHeight - _paddingBetweenRows * 2) / 3;

            return Column(
              children: controllers
                  .mapIndex(
                    (c, listIndex) => SizedBox(
                      height: partSize,
                      child: ListView.builder(
                        controller: c,
                        reverse: listIndex.isOdd,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, index) {
                          return _generateItem(
                            listIndex,
                            index % images[listIndex].length,
                            partSize,
                          );
                        },
                      ),
                    ),
                  )
                  .separated(const SizedBox(height: _paddingBetweenRows)),
            );
          },
        ),
      ),
    );
  }

  Widget _generateItem(int listIndex, int index, double size) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: size,
      height: size,
      decoration: BoxDecoration(color: images[listIndex][index], shape: BoxShape.circle),
    );
  }
}
