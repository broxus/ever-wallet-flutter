import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/blocs/account/account_creation_bloc.dart';
import '../../../../../../../../injection.dart';
import '../../../../design/design.dart';
import '../../../../design/utils.dart';
import '../../../../design/widgets/crystal_scaffold.dart';
import '../../../router.gr.dart';

class NewAccountNamePage extends StatefulWidget {
  final String publicKey;
  final WalletType walletType;

  const NewAccountNamePage({
    Key? key,
    required this.publicKey,
    required this.walletType,
  }) : super(key: key);

  @override
  _NewAccountNamePageState createState() => _NewAccountNamePageState();
}

class _NewAccountNamePageState extends State<NewAccountNamePage> {
  final nameController = TextEditingController();
  final accountCreationBloc = getIt.get<AccountCreationBloc>();

  @override
  void dispose() {
    nameController.dispose();
    accountCreationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: CrystalScaffold(
          onScaffoldTap: FocusScope.of(context).unfocus,
          headline: 'Name new account',
          body: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: buildBody(),
          ),
        ),
      );

  Widget buildBody() => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Stack(
          children: [
            CrystalTextFormField(
              controller: nameController,
              hintText: 'Name',
              keyboardType: TextInputType.text,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: buildActions(),
            ),
          ],
        ),
      );

  Widget buildActions() => ValueListenableBuilder<TextEditingValue>(
        valueListenable: nameController,
        builder: (BuildContext context, TextEditingValue value, Widget? child) {
          final double bottomPadding = math.max(getKeyboardInsetsBottom(context), 0) + 12;

          return AnimatedPadding(
            curve: Curves.decelerate,
            duration: kThemeAnimationDuration,
            padding: EdgeInsets.only(
              bottom: bottomPadding,
            ),
            child: CrystalButton(
              text: 'Next',
              onTap: () => onConfirm(value.text.isNotEmpty ? value.text : null),
            ),
          );
        },
      );

  void onConfirm([String? name]) {
    FocusScope.of(context).unfocus();

    accountCreationBloc.add(AccountCreationEvent.create(
      name: name ?? widget.walletType.describe(),
      publicKey: widget.publicKey,
      walletType: widget.walletType,
    ));

    context.router.navigate(const WalletRouterRoute());
  }
}
