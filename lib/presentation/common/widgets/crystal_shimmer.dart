import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme.dart';

class CrystalShimmer extends StatelessWidget {
  final double height;
  final double width;

  const CrystalShimmer({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: CrystalColor.modalBackground.withOpacity(0.2),
        highlightColor: CrystalColor.shimmerHighlight,
        child: Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(
            color: CrystalColor.whitelight,
            borderRadius: BorderRadius.zero,
          ),
        ),
      );
}
