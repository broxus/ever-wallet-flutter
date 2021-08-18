import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme.dart';
import 'animated_appearance.dart';
import 'dynamic_divider.dart';

class InformationField extends StatelessWidget {
  const InformationField({
    Key? key,
    required this.title,
    this.step = 4.0,
    required this.value,
    this.error = '',
    this.isLoading = false,
    this.fontSize = 14.0,
    this.letterSpacing = 0.75,
    this.titleColor = CrystalColor.fontTitleSecondaryDark,
    this.valueColor = CrystalColor.fontDark,
    this.shimmer,
  }) : super(key: key);

  final String title;
  final String value;
  final String error;
  final bool isLoading;

  final double step;
  final double fontSize;
  final double letterSpacing;

  final Color titleColor;
  final Color valueColor;
  final Widget? shimmer;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: fontSize,
              color: titleColor,
            ),
          ),
          CrystalDivider(height: step),
          if (isLoading)
            getShimmer()
          else
            Text(
              value,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: fontSize,
                letterSpacing: letterSpacing,
                color: valueColor,
              ),
            ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: AnimatedAppearance(
                child: Text(
                  error,
                  style: const TextStyle(
                    fontSize: 12.0,
                    letterSpacing: 0.4,
                    color: CrystalColor.error,
                  ),
                ),
              ),
            ),
        ],
      );

  Widget getShimmer() {
    if (shimmer != null) return shimmer!;

    return Shimmer.fromColors(
      baseColor: CrystalColor.modalBackground.withOpacity(0.2),
      highlightColor: CrystalColor.shimmerHighlight,
      child: Container(
        decoration: const BoxDecoration(
          color: CrystalColor.whitelight,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        height: fontSize + 3,
        width: 120,
      ),
    );
  }
}
