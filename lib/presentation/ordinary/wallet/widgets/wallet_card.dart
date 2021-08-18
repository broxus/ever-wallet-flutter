import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, HapticFeedback;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../domain/blocs/account/account_info_bloc.dart';
import '../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../../../design/extension.dart';
import '../../../design/widget/crystal_bottom_sheet.dart';
import '../modals/account_removement_body.dart';
import '../modals/connected_sites_body.dart';
import '../modals/preferences_body.dart';

class WalletCard extends StatefulWidget {
  final SubscriptionSubject subscriptionSubject;

  const WalletCard({
    Key? key,
    required this.subscriptionSubject,
  }) : super(key: key);

  @override
  _WalletCardState createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  final menuController = SelectionController();
  final addressController = SelectionController();
  final publicKeyController = SelectionController();
  late final TonWalletInfoBloc tonWalletInfoBloc;
  late final AccountInfoBloc accountInfoBloc;

  @override
  void initState() {
    super.initState();
    tonWalletInfoBloc = getIt.get<TonWalletInfoBloc>(param1: widget.subscriptionSubject.value.tonWallet);
    accountInfoBloc = getIt.get<AccountInfoBloc>(param1: widget.subscriptionSubject.value.accountSubject);
  }

  @override
  void dispose() {
    tonWalletInfoBloc.close();
    accountInfoBloc.close();
    menuController.dispose();
    addressController.dispose();
    publicKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          menuController.dismiss();
          addressController.dismiss();
          publicKeyController.dismiss();
        },
        child: AnimatedAppearance(
          child: Stack(
            children: [
              Container(
                height: 200,
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    stops: [0.0, 0.45],
                    colors: [
                      Color(0xFFA6AEBD),
                      CrystalColor.background,
                    ],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                    gradient: LinearGradient(
                      begin: const Alignment(-5, 2),
                      end: Alignment.topRight,
                      stops: const [0.0, 0.75],
                      colors: [
                        Colors.white.withOpacity(0.1),
                        CrystalColor.background,
                      ],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 17,
                        child: buildInfo(),
                      ),
                      Expanded(flex: 6, child: buildPattern()),
                    ],
                  ),
                ),
              ),
              BlocBuilder<TonWalletInfoBloc, TonWalletInfoState>(
                bloc: tonWalletInfoBloc,
                builder: (context, state) => state.maybeWhen(
                  ready: (
                    address,
                    contractState,
                    walletType,
                    details,
                    publicKey,
                  ) =>
                      Positioned(
                    top: 8,
                    right: 8,
                    child: buildMoreButton(address: address),
                  ),
                  orElse: () => const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildPattern() => ColoredBox(
        color: const Color(0xFFCDF8E4),
        child: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFC4C5EB), Color(0xFFBF70E6)],
          ).createShader(rect),
          blendMode: BlendMode.srcATop,
          child: Image.asset(
            Assets.images.accountCardPattern.path,
            color: Colors.white,
            fit: BoxFit.cover,
          ),
        ),
      );

  Widget buildInfo() => Padding(
        padding: const EdgeInsets.only(top: 23, left: 23.0, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<AccountInfoBloc, AccountInfoState>(
              bloc: accountInfoBloc,
              builder: (context, state) => state.maybeWhen(
                ready: (name) => AutoSizeText(
                  name,
                  maxLines: 1,
                  maxFontSize: 16.0,
                  style: const TextStyle(
                    fontSize: 16.0,
                    letterSpacing: 0.75,
                    color: CrystalColor.fontLight,
                  ),
                ),
                orElse: () => const SizedBox(),
              ),
            ),
            const CrystalDivider(height: 8),
            BlocBuilder<TonWalletInfoBloc, TonWalletInfoState>(
              bloc: tonWalletInfoBloc,
              builder: (context, state) => state.maybeWhen(
                ready: (_, __, ___, ____, publicKey) => buildNamedField(
                  controller: publicKeyController,
                  name: LocaleKeys.fields_public_key.tr(),
                  value: publicKey,
                ),
                orElse: () => buildNamedField(
                  controller: publicKeyController,
                  name: LocaleKeys.fields_public_key.tr(),
                  value: null,
                ),
              ),
            ),
            BlocBuilder<TonWalletInfoBloc, TonWalletInfoState>(
              bloc: tonWalletInfoBloc,
              builder: (context, state) => state.maybeWhen(
                ready: (address, _, __, ___, ____) => buildNamedField(
                  controller: addressController,
                  name: LocaleKeys.fields_address.tr(),
                  value: address,
                ),
                orElse: () => buildNamedField(
                  controller: addressController,
                  name: LocaleKeys.fields_address.tr(),
                  value: null,
                ),
              ),
            ),
            BlocBuilder<TonWalletInfoBloc, TonWalletInfoState>(
              bloc: tonWalletInfoBloc,
              builder: (context, state) => state.maybeWhen(
                ready: (_, __, walletType, ___, ____) => buildNamedField(
                  name: LocaleKeys.fields_type.tr(),
                  value: walletType.describe(),
                  isSelectable: false,
                ),
                orElse: () => buildNamedField(
                  name: LocaleKeys.fields_type.tr(),
                  value: null,
                  isSelectable: false,
                ),
              ),
            ),
            const Spacer(),
            BlocBuilder<TonWalletInfoBloc, TonWalletInfoState>(
              bloc: tonWalletInfoBloc,
              builder: (context, state) => state.maybeWhen(
                ready: (_, contractState, __, ___, ____) => Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: buildBalance(contractState.balance),
                ),
                orElse: () => const SizedBox(),
              ),
            ),
          ],
        ),
      );

  Widget buildNamedField({
    SelectionController? controller,
    required String name,
    required String? value,
    bool isSelectable = true,
    bool disabled = false,
  }) =>
      Row(
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14.0,
              letterSpacing: 0.75,
              color: CrystalColor.secondary,
            ),
          ),
          const CrystalDivider(width: 8),
          Flexible(
            child: value == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: buildShimmer(),
                  )
                : SelectionWidget(
                    controller: controller,
                    enabled: !disabled && isSelectable,
                    configuration: const SelectionConfiguration(
                      openOnTap: true,
                      openOnHold: false,
                      highlightColor: CrystalColor.secondaryBackground,
                    ),
                    overlay: (context) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Material(
                        type: MaterialType.card,
                        color: CrystalColor.background,
                        borderRadius: BorderRadius.circular(4.0),
                        clipBehavior: Clip.antiAlias,
                        child: CrystalInkWell(
                          splashColor: CrystalColor.secondary,
                          highlightColor: CrystalColor.secondary,
                          onTap: () {
                            controller?.dismiss();
                            HapticFeedback.selectionClick();
                            Clipboard.setData(ClipboardData(text: value));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 6.0,
                            ),
                            color: CrystalColor.secondaryBackground,
                            child: Text(
                              LocaleKeys.actions_copy.tr(),
                              style: const TextStyle(
                                color: CrystalColor.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: (onHold) => SizedBox(
                      height: 20,
                      child: ExtendedText(
                        value,
                        key: UniqueKey(),
                        maxLines: 1,
                        overflowWidget: TextOverflowWidget(
                          position: TextOverflowPosition.middle,
                          align: TextOverflowAlign.center,
                          child: Text(
                            '…',
                            style: TextStyle(
                              color: CrystalColor.secondary.withOpacity(!onHold && isSelectable ? 0.64 : 1.0),
                            ),
                          ),
                        ),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          height: 20.0 / 14.0,
                          fontSize: 14.0,
                          letterSpacing: 0.75,
                          color: CrystalColor.secondary.withOpacity(
                            disabled
                                ? 0.32
                                : !onHold && isSelectable
                                    ? 0.64
                                    : 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      );

  Widget buildBalance(String balance) {
    final balancePart = balance.split(".");

    return AutoSizeText.rich(
      TextSpan(
        text: balancePart[0],
        style: const TextStyle(
          fontSize: 24,
          letterSpacing: 0.75,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: ".${balancePart.last} TON",
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 0.75,
              fontWeight: FontWeight.normal,
            ),
          )
        ],
      ),
      maxLines: 1,
      minFontSize: 10,
    );
  }

  Widget buildMoreButton({
    required String address,
  }) =>
      SelectionWidget(
        controller: menuController,
        configuration: const SelectionConfiguration(
          hapticOnShown: false,
          openOnTap: true,
          openOnDoubleTap: false,
          autoClose: false,
          parentAnchor: Alignment.bottomRight,
          childAnchor: Alignment.topRight,
        ),
        overlay: (context) => Padding(
          padding: const EdgeInsets.only(right: 4.0, top: 4.0),
          child: Material(
            elevation: 1.0,
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(Platform.isIOS ? 13.0 : 4.0),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicWidth(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: PlatformWidget(
                      cupertino: (context, _) => BackdropFilter(
                        filter: ImageFilter.blur(sigmaY: 30, sigmaX: 30),
                        child: const ColoredBox(color: Colors.transparent),
                      ),
                    ),
                  ),
                  ColoredBox(
                    color: Platform.isIOS ? const Color.fromRGBO(237, 237, 237, 0.8) : CrystalColor.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildDropDownAction(
                          onTap: () {
                            menuController.dismiss();

                            CrystalBottomSheet.show(
                              context,
                              title: PreferencesBody.title,
                              body: PreferencesBody(
                                subscriptionSubject: widget.subscriptionSubject,
                              ),
                            );
                          },
                          title: PreferencesBody.title,
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 1.0,
                          color: Platform.isIOS ? const Color.fromRGBO(60, 60, 67, 0.36) : CrystalColor.divider,
                        ),
                        buildDropDownAction(
                          onTap: () {
                            menuController.dismiss();

                            CrystalBottomSheet.show(
                              context,
                              title: ConnectedSitesBody.title,
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              body: ConnectedSitesBody(
                                subscriptionSubject: widget.subscriptionSubject,
                              ),
                              expand: false,
                              avoidBottomInsets: false,
                              hasTitleDivider: true,
                            );
                          },
                          title: ConnectedSitesBody.title,
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 1.0,
                          color: Platform.isIOS ? const Color.fromRGBO(60, 60, 67, 0.36) : CrystalColor.divider,
                        ),
                        buildDropDownAction(
                          onTap: () {
                            menuController.dismiss();

                            CrystalBottomSheet.show(
                              context,
                              title: AccountRemovementBody.title,
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              body: AccountRemovementBody(
                                subscriptionSubject: widget.subscriptionSubject,
                              ),
                              expand: false,
                              avoidBottomInsets: false,
                              hasTitleDivider: true,
                            );
                          },
                          title: LocaleKeys.actions_remove_account.tr(),
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        child: (onHold) => Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.all(4),
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: CrystalColor.actionBackground.withOpacity(0.32),
          ),
          child: Center(
            child: Icon(
              Icons.more_horiz,
              color: onHold ? CrystalColor.secondary : CrystalColor.primary,
            ),
          ),
        ),
      );

  Widget buildDropDownAction({
    required String title,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) =>
      Material(
        type: MaterialType.transparency,
        child: CrystalInkWell(
          splashColor: CrystalColor.fontDark,
          highlightColor: CrystalColor.fontDark,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16.0,
                color: isDestructive ? CrystalColor.error : CrystalColor.fontDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );

  Widget buildShimmer({
    double height = 16,
    double width = 80,
  }) =>
      Container(
        constraints: BoxConstraints(maxHeight: height, maxWidth: width),
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2.0))),
        child: Shimmer.fromColors(
          baseColor: CrystalColor.shimmerBackground,
          highlightColor: CrystalColor.shimmerHighlight,
          child: Container(color: Colors.white),
        ),
      );
}
