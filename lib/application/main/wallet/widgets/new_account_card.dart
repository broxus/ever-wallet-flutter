import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/main/wallet/modals/add_account_flow/start_add_account_flow.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class NewAccountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AsyncValueStreamProvider<String?>(
        create: (context) => context.read<KeysRepository>().currentKeyStream,
        builder: (context, child) {
          final currentKey = context.watch<AsyncValue<String?>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return GestureDetector(
            onTap: () async {
              if (currentKey != null) {
                startAddAccountFlow(
                  context: context,
                  publicKey: currentKey,
                );
              }
            },
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
        },
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
          const Gap(24),
          _getAddButton(context),
          const Spacer(),
          Text(
            context.localization.add_account,
            style: style.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 78, 24),
            child: Text(
              context.localization.add_account_description,
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
