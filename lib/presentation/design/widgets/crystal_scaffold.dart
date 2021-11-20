import 'package:expand_tap_area/expand_tap_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../design.dart';

class CrystalScaffold extends StatelessWidget {
  const CrystalScaffold({
    Key? key,
    required this.headline,
    this.headlineSize = 24,
    this.onScaffoldTap,
    this.allowIosBackSwipe = true,
    this.onWillPop,
    required this.body,
    this.actions,
  }) : super(key: key);

  final Widget body;
  final String headline;
  final double headlineSize;
  final bool allowIosBackSwipe;
  final Widget? actions;
  final Future<bool> Function()? onWillPop;
  final VoidCallback? onScaffoldTap;

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: onWillPop ?? (allowIosBackSwipe ? null : () async => true),
        child: GestureDetector(
          onTap: onScaffoldTap,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ExpandTapWidget(
                        onTap: context.router.pop,
                        tapPadding: const EdgeInsets.all(16),
                        child: Material(
                          type: MaterialType.transparency,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, top: 12),
                            child: SizedBox(
                              height: 24,
                              child: PlatformWidget(
                                material: (context, _) => Assets.images.iconBackAndroid.image(
                                  color: CrystalColor.accent,
                                  width: 24,
                                ),
                                cupertino: (context, _) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.arrow_back_ios_sharp,
                                      color: CrystalColor.accent,
                                      size: 14,
                                    ),
                                    const CrystalDivider(width: 3),
                                    Text(
                                      LocaleKeys.actions_back.tr(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: CrystalColor.accent,
                                        letterSpacing: 0.75,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (actions != null) actions!,
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              headline,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: headlineSize,
                                color: CrystalColor.fontDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const CrystalDivider(height: 8),
                          Expanded(child: body),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
