import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/key/current_key_provider.dart';
import '../../../../generated/codegen_loader.g.dart';
import '../../../common/theme.dart';
import '../modals/add_account_flow/start_add_account_flow.dart';

class NewAccountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) => GestureDetector(
          onTap: () async {
            final currentKey = await ref.read(currentKeyProvider.future);

            if (currentKey != null) {
              startAddAccountFlow(
                context: context,
                publicKey: currentKey.publicKey,
              );
            }
          },
          child: child,
        ),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: CrystalColor.background,
            gradient: const LinearGradient(
              colors: [
                Colors.white60,
                Colors.white38,
              ],
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: CrystalColor.background,
              gradient: LinearGradient(
                begin: const Alignment(-5, 2),
                end: Alignment.topRight,
                stops: const [0, 0.75],
                colors: [
                  Colors.white.withOpacity(0.1),
                  CrystalColor.fontSecondaryLight,
                ],
              ),
            ),
            child: _getContent(context),
          ),
        ),
      );

  Widget _getContent(BuildContext context) {
    const style = TextStyle(
      letterSpacing: 0.75,
      color: CrystalColor.fontHeaderDark,
    );

    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _getAddButton(context),
          const Spacer(),
          Text(
            LocaleKeys.add_account.tr(),
            style: style.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 78, 24),
            child: Text(
              LocaleKeys.add_account_description.tr(),
              style: style.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAddButton(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: ShapeDecoration(
          shape: const CircleBorder(),
          color: CrystalColor.background.withOpacity(0.1),
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: CrystalColor.background,
          ),
        ),
      );
}
