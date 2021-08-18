part of 'deploy_wallet_flow.dart';

class DeployBody extends StatefulWidget {
  const DeployBody({Key? key}) : super(key: key);

  @override
  _DeployBodyState createState() => _DeployBodyState();
}

class _DeployBodyState extends State<DeployBody> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: BlocBuilder<TonWalletDeploymentBloc, TonWalletDeploymentState>(
        buildWhen: (prev, next) => next.maybeMap(
          initial: (_) => true,
          orElse: () => false,
        ),
        builder: (context, state) => state.maybeMap(
          orElse: () => const SizedBox(),
          initial: (initial) => messagePreparingBody(
            balance: initial.balance,
          ),
        ),
      ),
    );
  }

  Widget messagePreparingBody({String? balance}) =>
      BlocBuilder<TonWalletDeploymentFeesBloc, TonWalletDeploymentFeesState>(
        bloc: context.watch<TonWalletDeploymentBloc>().feesBloc,
        builder: (context, state) {
          final isInsufficientFunds = state.maybeMap(orElse: () => true, ready: (_) => false);
          state.maybeMap(
            orElse: () => null,
          );
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _getInfo(balance: balance, feesState: state),
              CrystalButton(
                text: LocaleKeys.actions_deploy.tr(),
                onTap: isInsufficientFunds
                    ? null
                    : () {
                        context.read<TonWalletDeploymentBloc>().add(const TonWalletDeploymentEvent.goToPassword());
                      },
              ),
            ],
          );
        },
      );

  Widget unknownContractBody(String address) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocaleKeys.receive_wallet_modal_title.tr(args: ['']),
              style: const TextStyle(
                fontSize: 16.0,
                color: CrystalColor.fontDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const CrystalDivider(height: 8),
            AddressCard(address: address),
            const CrystalDivider(height: 24),
            CrystalButton(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: address));
                CrystalFlushbar.show(context, message: LocaleKeys.receive_wallet_modal_message_copied.tr());
              },
              text: LocaleKeys.receive_wallet_modal_actions_copy.tr(),
            ),
          ],
        ),
      );

  Widget _getInfo({
    String? balance,
    required TonWalletDeploymentFeesState feesState,
  }) =>
      Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 24),
        color: CrystalColor.grayBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _getInfoRow(
              title: LocaleKeys.fields_account_balance.tr(),
              value: balance != null
                  ? LocaleKeys.deploy_asset_modal_value.tr(args: [
                      balance,
                      'TON',
                    ])
                  : null,
            ),
            const SizedBox(
              height: 16,
            ),
            feesState.maybeMap(
              orElse: () => const SizedBox(),
              loading: (_) => getFeesRow(
                null,
                isLoading: true,
              ),
              ready: (ready) => getFeesRow(
                ready.fees,
              ),
            ),
            feesState.maybeMap(
              orElse: () => const SizedBox(),
              insufficientFunds: (_) => getErrorWidget(),
              unknownContract: (_) => getErrorWidget(),
            ),
          ],
        ),
      );

  Widget getFeesRow(String? fees, {bool isLoading = false}) => _getInfoRow(
        title: LocaleKeys.fields_fee.tr(),
        value: fees != null
            ? LocaleKeys.deploy_asset_modal_value.tr(args: [
                '~$fees',
                'TON',
              ])
            : null,
        isLoading: isLoading,
      );

  Widget _getInfoRow({required String title, String? value, bool isLoading = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: CrystalColor.fontTitleSecondaryDark,
              fontSize: 16,
            ),
          ),
          const CrystalDivider(height: 4),
          if (!isLoading)
            Text(
              value ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: CrystalColor.fontDark,
              ),
            )
          else
            Shimmer.fromColors(
              baseColor: CrystalColor.modalBackground.withOpacity(0.2),
              highlightColor: CrystalColor.whitelight,
              child: Container(
                decoration: const BoxDecoration(
                  color: CrystalColor.whitelight,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                height: 20,
                width: 80,
              ),
            ),
        ],
      );

  Widget getErrorWidget() => SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: AnimatedAppearance(
            child: AutoSizeText(
              LocaleKeys.deploy_wallet_modal_unavailable_message
                  .tr(args: [1.0.toStringAsCrypto(minimumFractionDigits: 0)]),
              maxFontSize: 14,
              style: const TextStyle(
                letterSpacing: 0.4,
                color: CrystalColor.error,
              ),
            ),
          ),
        ),
      );
}
