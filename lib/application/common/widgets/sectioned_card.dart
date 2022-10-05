import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SectionedCard extends StatelessWidget {
  final List<Widget> sections;

  const SectionedCard({
    super.key,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
            itemCount: sections.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => sections[index],
            separatorBuilder: (context, index) => const Gap(16),
          ),
        ),
      );
}
