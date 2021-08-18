part of 'send_transaction_flow.dart';

class _LoaderBody extends StatelessWidget {
  const _LoaderBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: BlocBuilder<TonWalletTransferBloc, TonWalletTransferState>(
          builder: (context, state) {
            final animation = state.maybeMap(
              orElse: () => const SizedBox(),
              success: (_) => Lottie.asset('assets/animations/done.json'),
              error: (_) => Lottie.asset('assets/animations/failed.json'),
              sending: (_) => Lottie.asset('assets/animations/money.json'),
            );
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 160,
                  child: animation,
                ),
                if (state.maybeMap(
                  success: (_) => true,
                  error: (_) => true,
                  orElse: () => false,
                ))
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: AnimatedAppearance(
                      child: CrystalButton(
                        text: LocaleKeys.actions_ok.tr(),
                        onTap: Navigator.of(context).maybePop,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
}
