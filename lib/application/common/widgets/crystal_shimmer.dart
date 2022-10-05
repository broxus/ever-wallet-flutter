import 'package:ever_wallet/application/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CrystalShimmer extends StatelessWidget {
  final double? height;
  final double? width;

  const CrystalShimmer({
    super.key,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: CrystalColor.modalBackground.withOpacity(0.2),
        highlightColor: CrystalColor.shimmerHighlight,
        child: Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(
            color: CrystalColor.whitelight,
          ),
        ),
      );
}
