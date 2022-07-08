import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../util/extensions/iterable_extensions.dart';

const _paddingBetweenRows = 16.0;

/// Panel of sliding block chains on main screen
class SlidingBlockChains extends StatefulWidget {
  const SlidingBlockChains({Key? key}) : super(key: key);

  @override
  State<SlidingBlockChains> createState() => _SlidingBlockChainsState();
}

class _SlidingBlockChainsState extends State<SlidingBlockChains> {
  Timer? timer;
  final controllers = List.generate(3, (_) => ScrollController());
  final images = <List<String>>[
    [
      'layer1/btc.svg',
      'layer1/eth.svg',
      'layer1/usdt.svg',
      'layer1/DOGE.svg',
      'layer1/dot.svg',
      'layer1/MATIC.svg',
      'layer1/dai.svg',
      'layer1/QUBE.svg',
      'layer1/EVER.svg',
      'layer1/bridge.svg',
    ],
    [
      'layer2/usdc.svg',
      'layer2/AVAX.svg',
      'layer2/xrp.svg',
      'layer2/bnb.svg',
      'layer2/ADA.svg',
      'layer2/SOL.svg',
      'layer2/SHIB.svg',
      'layer2/LUNA.svg',
      'layer2/NEAR.svg',
      'layer2/CRO.svg',
    ],
    [
      'layer3/atom.svg',
      'layer3/ltc.svg',
      'layer3/trx.svg',
      'layer3/xlm.svg',
      'layer3/link.svg',
      'layer3/mana.svg',
      'layer3/FTM.svg',
      'layer3/HBAR.svg',
      'layer3/AXS.svg',
      'layer3/AAVE.svg',
    ],
  ];

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _initTimer() =>
      timer = Timer.periodic(const Duration(milliseconds: 30), (timer) => _scrollLists());

  void _stopTimer() {
    timer?.cancel();
    timer = null;
  }

  void _scrollLists() => controllers.forEach((c) => c.jumpTo(c.offset + 0.5));

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('SlidingBlockChains'),
      onVisibilityChanged: (info) {
        final isVisible = info.visibleBounds != Rect.zero;
        if (isVisible && timer == null) {
          _initTimer();
        } else if (!isVisible) {
          _stopTimer();
        }
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final partSize = (constraints.maxHeight - _paddingBetweenRows * 2) / 3;

              return Column(
                children: controllers
                    .mapIndex(
                      (c, listIndex) => SizedBox(
                        height: partSize,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
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
      ),
    );
  }

  Widget _generateItem(int listIndex, int index, double size) {
    return Container(
      key: ValueKey('OnboardingImage_${images[listIndex][index]}'),
      margin: const EdgeInsets.only(right: 16),
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: SvgPicture.asset('assets/images/onboarding/${images[listIndex][index]}'),
    );
  }
}
