import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/crystal_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SectionedCardSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool hasError;
  final bool isSelectable;

  const SectionedCardSection({
    Key? key,
    required this.title,
    required this.subtitle,
    this.hasError = false,
    this.isSelectable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const Gap(4),
          if (subtitle != null) subtitleText() else shimmer(),
        ],
      );

  Widget subtitleText() => isSelectable
      ? SelectableText(
          subtitle!,
          style: subtitleStyle(),
        )
      : Text(
          subtitle!,
          style: subtitleStyle(),
        );

  TextStyle subtitleStyle() => TextStyle(
        fontSize: 16,
        color: hasError ? CrystalColor.error : null,
      );

  Widget shimmer() => const CrystalShimmer(
        height: 16,
        width: 120,
      );
}
