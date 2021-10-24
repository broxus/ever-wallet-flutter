import 'dart:math' as math;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../domain/blocs/account/account_info_bloc.dart';
import '../../../../domain/blocs/account/account_renaming_bloc.dart';
import '../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../domain/utils/explorer.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';

class PreferencesBody extends StatefulWidget {
  final String address;

  const PreferencesBody({
    Key? key,
    required this.address,
  }) : super(key: key);

  static String get title => LocaleKeys.preferences_modal_title.tr();

  @override
  _PreferencesBodyState createState() => _PreferencesBodyState();
}

class _PreferencesBodyState extends State<PreferencesBody> {
  final textFocus = FocusNode();
  final scrollController = ScrollController();
  final accountRenamingBloc = getIt.get<AccountRenamingBloc>();
  final textController = TextEditingController();
  final tonWalletInfoBloc = getIt.get<TonWalletInfoBloc>();
  final accountInfoBloc = getIt.get<AccountInfoBloc>();

  @override
  void initState() {
    super.initState();
    tonWalletInfoBloc.add(TonWalletInfoEvent.load(widget.address));
    accountInfoBloc.add(AccountInfoEvent.load(widget.address));
  }

  @override
  void didUpdateWidget(covariant PreferencesBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    tonWalletInfoBloc.add(TonWalletInfoEvent.load(widget.address));
    accountInfoBloc.add(AccountInfoEvent.load(widget.address));
  }

  @override
  void dispose() {
    textFocus.unfocus();
    textFocus.dispose();
    textController.dispose();
    scrollController.dispose();
    accountRenamingBloc.close();
    tonWalletInfoBloc.close();
    accountInfoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TonWalletInfoBloc, TonWalletInfoState?>(
        bloc: tonWalletInfoBloc,
        builder: (context, state) => state != null
            ? GestureDetector(
                onTap: textFocus.unfocus,
                child: FadingEdgeScrollView.fromScrollView(
                  child: ListView(
                    shrinkWrap: true,
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      top: 24,
                      bottom: math.max(16, context.safeArea.bottom),
                    ),
                    children: [
                      getNameTextField(),
                      const CrystalDivider(height: 24),
                      AddressCard(address: state.address),
                      const CrystalDivider(height: 24),
                      CrystalButton(
                        type: CrystalButtonType.outline,
                        text: LocaleKeys.preferences_modal_actions_look_in_the_explorer.tr(),
                        onTap: () => launch(getAccountExplorerLink(state.address)),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
      );

  Widget getNameTextField() => BlocConsumer<AccountInfoBloc, AccountInfoState?>(
        bloc: accountInfoBloc,
        listener: (context, state) {
          if (state != null && textController.text != state.account.name) {
            showCrystalFlushbar(
              context,
              message: LocaleKeys.preferences_modal_message_renamed.tr(),
            );
          }
        },
        builder: (context, state) {
          if (state != null) {
            textController.text = state.account.name;
            textController.selection = TextSelection.collapsed(offset: state.account.name.length);

            return CrystalTextFormField(
              controller: textController,
              focusNode: textFocus,
              hintText: '${LocaleKeys.wallet_screen_add_account_hint.tr()}…',
              maxLength: 24,
              formatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z -_]')),
                FilteringTextInputFormatter.deny('  ', replacementString: ' '),
              ],
              suffix: getSaveButton(state.account.name),
            );
          } else {
            return const SizedBox();
          }
        },
      );

  Widget getSaveButton(String name) => ValueListenableBuilder<TextEditingValue>(
        valueListenable: textController,
        builder: (context, value, child) => AnimatedSwitcher(
          duration: kThemeAnimationDuration,
          child: value.text.trim() != name
              ? GestureDetector(
                  onTap: () => accountRenamingBloc.add(AccountRenamingEvent.rename(
                    address: widget.address,
                    name: value.text,
                  )),
                  behavior: HitTestBehavior.opaque,
                  child: child,
                )
              : const SizedBox(),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 20, 10),
          child: Text(
            LocaleKeys.actions_save.tr(),
            style: const TextStyle(
              color: CrystalColor.accent,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.25,
            ),
          ),
        ),
      );
}
