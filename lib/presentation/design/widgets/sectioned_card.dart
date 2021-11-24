import 'package:flutter/material.dart';

class Section {
  final String title;
  final String subtitle;

  const Section({
    required this.title,
    required this.subtitle,
  });
}

class SectionedCard extends StatelessWidget {
  final List<Section> sections;

  const SectionedCard({
    Key? key,
    required this.sections,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
            itemCount: sections.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => section(
              title: sections[index].title,
              subtitle: sections[index].subtitle,
            ),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
        ),
      );

  Widget section({
    required String title,
    required String subtitle,
  }) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      );
}
