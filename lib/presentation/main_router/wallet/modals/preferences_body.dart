import 'dart:math' as math;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../domain/blocs/account/account_info_bloc.dart';
import '../../../../domain/blocs/account/account_renaming_bloc.dart';
import '../../../../domain/blocs/ton_wallet/ton_wallet_info_bloc.dart';
import '../../../../domain/utils/explorer.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';

class PreferencesBody extends StatefulWidget {
  final SubscriptionSubject subscriptionSubject;

  const PreferencesBody({
    Key? key,
    required this.subscriptionSubject,
  }) : super(key: key);

  static String get title => LocaleKeys.preferences_modal_title.tr();

  @override
  _PreferencesBodyState createState() => _PreferencesBodyState();
}

class _PreferencesBodyState extends State<PreferencesBody> {
  final _textFocus = FocusNode();
  final _scrollController = ScrollController();
  final accountRenamingBloc = getIt.get<AccountRenamingBloc>();
  late final TextEditingController _textController;
  late final TonWalletInfoBloc tonWalletInfoBloc;
  late final AccountInfoBloc accountInfoBloc;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.subscriptionSubject.value.accountSubject.value.name);
    tonWalletInfoBloc = getIt.get<TonWalletInfoBloc>(param1: widget.subscriptionSubject.value.tonWallet);
    accountInfoBloc = getIt.get<AccountInfoBloc>(param1: widget.subscriptionSubject.value.accountSubject);
  }

  @override
  void dispose() {
    _textFocus.unfocus();
    _textFocus.dispose();
    _textController.dispose();
    _scrollController.dispose();
    accountRenamingBloc.close();
    tonWalletInfoBloc.close();
    accountInfoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TonWalletInfoBloc, TonWalletInfoState>(
        bloc: tonWalletInfoBloc,
        builder: (context, state) => state.maybeWhen(
          ready: (address, _, __, ___, ____) => GestureDetector(
            onTap: _textFocus.unfocus,
            child: FadingEdgeScrollView.fromScrollView(
              child: ListView(
                shrinkWrap: true,
                controller: _scrollController,
                padding: EdgeInsets.only(
                  top: 24,
                  bottom: math.max(16, context.safeArea.bottom),
                ),
                children: [
                  getNameTextField(),
                  const CrystalDivider(height: 24),
                  AddressCard(address: address),
                  const CrystalDivider(height: 24),
                  CrystalButton(
                    type: CrystalButtonType.outline,
                    text: LocaleKeys.preferences_modal_actions_look_in_the_explorer.tr(),
                    onTap: () => launch(getAccountExplorerLink(address)),
                  ),
                ],
              ),
            ),
          ),
          orElse: () => const SizedBox(),
        ),
      );

  Widget getNameTextField() => BlocConsumer<AccountInfoBloc, AccountInfoState>(
        bloc: accountInfoBloc,
        listener: (context, state) {
          state.map(
            ready: (_) => showCrystalFlushbar(
              context,
              message: LocaleKeys.preferences_modal_message_renamed.tr(),
            ),
            error: (_) => showErrorCrystalFlushbar(
              context,
              message: LocaleKeys.preferences_modal_message_renaming_error.tr(),
            ),
          );
        },
        builder: (context, state) => state.maybeWhen(
          ready: (name) {
            _textController.text = name;
            _textController.selection = TextSelection.collapsed(offset: name.length);
            return CrystalTextFormField(
                controller: _textController,
                focusNode: _textFocus,
                hintText: '${LocaleKeys.wallet_screen_add_account_hint.tr()}…',
                maxLength: 24,
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z -_]')),
                  FilteringTextInputFormatter.deny('  ', replacementString: ' '),
                ],
                suffix: getSaveButton(name));
          },
          orElse: () => const SizedBox(),
        ),
      );

  Widget getSaveButton(String name) => ValueListenableBuilder<TextEditingValue>(
        valueListenable: _textController,
        builder: (context, value, child) => AnimatedSwitcher(
          duration: kThemeAnimationDuration,
          child: value.text.trim() != name
              ? GestureDetector(
                  onTap: () => accountRenamingBloc.add(AccountRenamingEvent.rename(
                    accountSubject: widget.subscriptionSubject.value.accountSubject,
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
