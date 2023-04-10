import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/button/primary_button.dart';
import 'package:ever_wallet/application/common/general/default_appbar.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/common/general/tabbar.dart';
import 'package:ever_wallet/application/common/general/utils/change_notifier_listener.dart';
import 'package:ever_wallet/application/main/wallet/modals/utils.dart';
import 'package:ever_wallet/application/main/wallet/stever/stever_cancel_unstaking_screen.dart';
import 'package:ever_wallet/application/main/wallet/stever/stever_cubit/stever_cubit.dart';
import 'package:ever_wallet/application/main/wallet/stever/stever_how_it_works_sheet.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/application/util/extensions/iterable_extensions.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:ever_wallet/data/models/stever/stever_withdraw_request.dart';
import 'package:ever_wallet/data/repositories/stever_repository.dart';
import 'package:ever_wallet/data/repositories/token_currencies_repository.dart';
import 'package:ever_wallet/data/repositories/token_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/ton_wallets_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StEverScreenRoute extends MaterialPageRoute<void> {
  StEverScreenRoute(String accountAddress)
      : super(builder: (_) => StEverScreen(accountAddress: accountAddress));
}

/// Main screen to stake/unstake ever
class StEverScreen extends StatefulWidget {
  const StEverScreen({
    required this.accountAddress,
    super.key,
  });

  final String accountAddress;

  @override
  State<StEverScreen> createState() => _StEverScreenState();
}

class _StEverScreenState extends State<StEverScreen> {
  late StEverCubit cubit;
  final inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    cubit = StEverCubit(
      stEverRepository: context.read<StEverRepository>(),
      accountAddress: widget.accountAddress,
      tokenWalletsRepository: context.read<TokenWalletsRepository>(),
      tonWalletsRepository: context.read<TonWalletsRepository>(),
      currencyLoader: (contract) => context
          .read<TokenCurrenciesRepository>()
          .getCurrencyForContract(context.read<TransportRepository>().transport, contract),
      navigator: Navigator.of(context),
    );

    final wasOpened = context.read<HiveSource>().wasStEverOpened;
    if (!wasOpened) {
      context.read<HiveSource>().saveWasStEverOpened();
      WidgetsBinding.instance.addPostFrameCallback((_) => showStEverHowItWorksSheet(context));
    }
  }

  @override
  void dispose() {
    cubit.close();
    inputFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    return GestureDetector(
      onTap: () => inputFocus.unfocus(),
      child: Scaffold(
        appBar: DefaultAppBar(
          backText: localization.back_word,
          needDivider: false,
          backColor: ColorsRes.bluePrimary400,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localization.simple_staking_title, style: StylesRes.header2Faktum),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${localization.stake_ever_recieve_stever} ',
                            style: StylesRes.regular16,
                          ),
                          TextSpan(
                            text: localization.how_it_works,
                            style:
                                StylesRes.medium14Caption.copyWith(color: ColorsRes.bluePrimary400),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => showStEverHowItWorksSheet(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<StEverCubit, StEverCubitState>(
                      bloc: cubit,
                      builder: (context, state) {
                        final type = state.type;

                        final requests = state.requests;
                        final hasRequests = requests?.isNotEmpty ?? false;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EWTabBar<StakeType>(
                              values: [
                                StakeType.stake,
                                StakeType.unstake,
                                if (hasRequests) StakeType.inProgress
                              ],
                              builder: (_, v, isSelected) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      v.title(context),
                                      style: StylesRes.medium16.copyWith(
                                        color: isSelected
                                            ? ColorsRes.bluePrimary400
                                            : ColorsRes.neutral800,
                                      ),
                                    ),
                                    if (v == StakeType.inProgress && requests != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: ColorsRes.blue950,
                                        ),
                                        child: Text(
                                          requests.length.toString(),
                                          style: StylesRes.medium12.copyWith(
                                            color: ColorsRes.bluePrimary400,
                                          ),
                                        ),
                                      ),
                                    ]
                                  ],
                                );
                              },
                              selectedValue: type,
                              onChanged: (v) {
                                inputFocus.unfocus();
                                cubit.changeTab(v);
                              },
                              selectedColor: ColorsRes.bluePrimary400,
                              unselectedColor: ColorsRes.neutral800,
                              expanded: true,
                            ),
                            const SizedBox(height: 24),
                            if (type == StakeType.inProgress)
                              _inProgressBody(state)
                            else
                              _basicBody(state),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<StEverCubit, StEverCubitState>(
              bloc: cubit,
              builder: (context, state) {
                final buttonText = state.type.title(context);
                if (state.type == StakeType.inProgress) return const SizedBox.shrink();

                final isInactive = (state.isLoading ?? false) || !(state.canPressButton ?? true);
                return SafeArea(
                  minimum: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                  child: PrimaryButton(
                    text: buttonText,
                    onPressed: isInactive ? null : () => cubit.doAction(),
                    backgroundColor: isInactive ? ColorsRes.blue900 : ColorsRes.bluePrimary400,
                    style: StylesRes.buttonText.copyWith(color: ColorsRes.white),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Body for stake/unstake type
  Widget _basicBody(StEverCubitState state) {
    String tokenTicker;
    SvgPicture tokenIcon;
    final balance = state.balance;
    final enteredPrice = state.enteredPrice;
    switch (state.type) {
      case StakeType.stake:
        tokenTicker = kEverTicker;
        tokenIcon = Assets.images.ever.svg(width: 24, height: 24);
        break;
      case StakeType.unstake:
      default:
        tokenTicker = kStEverTicker;
        tokenIcon = Assets.images.stever.stever.svg(width: 24, height: 24);
        break;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stakeInput(
          ticker: tokenTicker,
          icon: tokenIcon,
          balance: balance,
          enteredPrice: enteredPrice,
        ),
        const SizedBox(height: 20),
        _additionalInfo(
          context: context,
          attachedAmount: state.attachedAmount,
          receive: state.receive,
          type: state.type,
          exchangeRate: state.exchangeRate,
        ),
      ],
    );
  }

  /// Body for inProgress type
  Widget _inProgressBody(StEverCubitState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: state.requests
              ?.map((r) => _requestItem(r, state))
              .separated(const DefaultDivider())
              .toList() ??
          [],
    );
  }

  Widget _stakeInput({
    required String ticker,
    required SvgPicture icon,
    required String? enteredPrice,
    required String? balance,
  }) {
    return ChangeNotifierListener(
      changeNotifier: inputFocus,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: inputFocus.hasFocus ? ColorsRes.bluePrimary400 : ColorsRes.neutral750,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cubit.inputController,
                      focusNode: inputFocus,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true, // this allows displaying text keyboard on ios
                        decimal: true,
                      ),
                      style: StylesRes.medium24.copyWith(color: ColorsRes.black),
                      cursorColor: ColorsRes.black,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        constraints: const BoxConstraints(maxHeight: 30),
                        hintStyle: StylesRes.medium24.copyWith(color: ColorsRes.neutral600),
                        hintText: '0.0',
                      ),
                      inputFormatters: [
                        // allow only float numbers
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      icon,
                      const SizedBox(width: 6),
                      Text(
                        ticker,
                        style: StylesRes.medium18.copyWith(color: ColorsRes.black),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '\$${enteredPrice ?? '0'}',
                      style: StylesRes.regular14.copyWith(color: ColorsRes.neutral400),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PrimaryButton(
                        fillWidth: false,
                        height: 25,
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        backgroundColor: ColorsRes.blue950,
                        text: context.localization.max.toUpperCase(),
                        style: StylesRes.medium14.copyWith(color: ColorsRes.bluePrimary400),
                        onPressed: () => cubit.selectMax(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.localization.balance_with_amount(balance ?? '0.0'),
                        style: StylesRes.regular14.copyWith(color: ColorsRes.neutral400),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _additionalInfo({
    required BuildContext context,
    required StakeType type,
    required String? attachedAmount,
    required String? receive,
    required double? exchangeRate,
  }) {
    final localization = context.localization;
    return Column(
      children: [
        _infoItem(
          title: localization.exchange_rate,
          value: '1 $kStEverTicker ≈ ${(exchangeRate ?? 1.0).toStringAsFixed(4)} $kEverTicker',
        ),
        _infoItem(
          title: localization.attached_amount,
          value: '${attachedAmount ?? ''} $kEverTicker',
        ),
        const DefaultDivider(),
        const SizedBox(height: 8),
        _infoItem(
          title: localization.receive,
          value: '${receive ?? '0'} ${type.swapTicker}',
          isBold: true,
        ),
        if (type == StakeType.stake) _infoItem(title: localization.current_apy, value: '12%'),
        if (type == StakeType.unstake) _unstakeNote(),
      ],
    );
  }

  Widget _infoItem({
    required String title,
    required String value,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: StylesRes.regular16.copyWith(color: ColorsRes.neutral400, letterSpacing: 0.25),
          ),
          Text(
            value,
            style: StylesRes.regular16.copyWith(
              color: ColorsRes.black,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _unstakeNote() {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(12),
        color: ColorsRes.blue950,
        child: Text(
          context.localization.withdraw_36_hours_note,
          style: StylesRes.medium14.copyWith(color: ColorsRes.black),
        ),
      ),
    );
  }

  Widget _requestItem(StEverWithdrawRequest request, StEverCubitState state) {
    return GestureDetector(
      onTap: () => showEWBottomSheet<void>(
        context,
        openFullScreen: true,
        title: transactionTextLongTimeFormat.format(int.parse(request.data.timestamp).toDateTime()),
        body: (_) => StEverCancelUnstakingSheet(
          request: request,
          exchangeRate: state.exchangeRate ?? 1.0,
          publicKey: cubit.accountPublicKey,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${request.data.amount.toTokensFull()} $kEverTicker',
                  style: StylesRes.medium14.copyWith(color: ColorsRes.black),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: ColorsRes.neutral600),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.accountAddress.ellipseAddress(),
                      style: StylesRes.regular14.copyWith(color: ColorsRes.black),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: ColorsRes.caution.withOpacity(0.1),
                      ),
                      child: Text(
                        context.localization.unstaking_progress,
                        style: StylesRes.captionText.copyWith(color: ColorsRes.caution),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                transactionTextShortTimeFormat.format(
                  int.parse(request.data.timestamp).toDateTime(),
                ),
                style: StylesRes.regular14.copyWith(color: ColorsRes.black),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

extension _StakeTypeX on StakeType {
  String title(BuildContext context) {
    switch (this) {
      case StakeType.stake:
        return context.localization.stake_word;
      case StakeType.unstake:
        return context.localization.unstake_word;
      case StakeType.inProgress:
        return context.localization.in_progress;
    }
  }

  /// Ticker that will be got after swapping
  String get swapTicker {
    switch (this) {
      case StakeType.stake:
        return kStEverTicker;
      case StakeType.unstake:
        return kEverTicker;
      case StakeType.inProgress:
        return '';
    }
  }
}
