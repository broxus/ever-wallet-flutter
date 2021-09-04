import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../domain/blocs/key/keys_bloc.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';
import '../../../design/utils.dart';
import '../../../design/widget/crystal_scaffold.dart';
import '../../../router.gr.dart';

class NewAccountNamePage extends StatefulWidget {
  @override
  _NewAccountNamePageState createState() => _NewAccountNamePageState();
}

class _NewAccountNamePageState extends State<NewAccountNamePage> {
  final nameController = TextEditingController();
  final keysBloc = getIt.get<KeysBloc>();

  @override
  void dispose() {
    nameController.dispose();
    keysBloc.close();
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

  Widget buildActions() => BlocBuilder<KeysBloc, KeysState>(
        bloc: keysBloc,
        builder: (context, state) {
          final keySubject = state.maybeWhen(
            ready: (keys, currentKey) => currentKey,
            orElse: () => null,
          );

          return ValueListenableBuilder<TextEditingValue>(
            valueListenable: nameController,
            builder: (BuildContext context, TextEditingValue value, Widget? child) {
              final double bottomPadding = math.max(getKeyboardInsetsBottom(context), 0) + 12;

              return AnimatedPadding(
                curve: Curves.decelerate,
                duration: kThemeAnimationDuration,
                padding: EdgeInsets.only(
                  bottom: bottomPadding,
                ),
                child: AnimatedAppearance(
                  showing: value.text.isNotEmpty && keySubject != null,
                  duration: const Duration(milliseconds: 350),
                  child: CrystalButton(
                    text: 'Next',
                    onTap: () => onConfirm(
                      keySubject: keySubject!,
                      name: value.text,
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

  void onConfirm({
    required KeySubject keySubject,
    required String name,
  }) {
    FocusScope.of(context).unfocus();

    context.router.push(NewAccountTypeRoute(
      keySubject: keySubject,
      accountName: name,
    ));
  }
}
