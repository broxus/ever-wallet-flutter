import 'package:flutter/material.dart';

import '../../common/general/default_appbar.dart';
import '../../common/general/default_divider.dart';
import '../../util/colors.dart';
import '../../util/extensions/context_extensions.dart';

class ManageSeedsRoute extends MaterialPageRoute<void> {
  ManageSeedsRoute() : super(builder: (_) => const ManageSeedsScreen());
}

class ManageSeedsScreen extends StatefulWidget {
  const ManageSeedsScreen({Key? key}) : super(key: key);

  @override
  State<ManageSeedsScreen> createState() => _ManageSeedsScreenState();
}

class _ManageSeedsScreenState extends State<ManageSeedsScreen> {
  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final themeStyle = context.themeStyle;

    return Scaffold(
      appBar: DefaultAppBar(
        backText: localization.profile,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                // TODO: replace text
                'Manage seeds & subscriptions',
                style: themeStyle.styles.header3Style,
              ),
            ),
            Text('Seed phrases', style: themeStyle.styles.sectionCaption),
            const DefaultDivider(),
          ],
        ),
      ),
    );
  }
}
