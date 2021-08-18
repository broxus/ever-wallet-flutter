import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../domain/blocs/key/key_removement_bloc.dart';
import '../../../injection.dart';
import '../../design/design.dart';

class RemoveSeedPhraseModalBody extends StatefulWidget {
  final KeySubject keySubject;

  const RemoveSeedPhraseModalBody({
    Key? key,
    required this.keySubject,
  }) : super(key: key);

  static String get title => LocaleKeys.remove_seed_modal_title.tr();

  @override
  _RemoveSeedPhraseModalBodyState createState() => _RemoveSeedPhraseModalBodyState();
}

class _RemoveSeedPhraseModalBodyState extends State<RemoveSeedPhraseModalBody> {
  final bloc = getIt.get<KeyRemovementBloc>();

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        minimum: const EdgeInsets.only(bottom: 16.0),
        child: BlocListener<KeyRemovementBloc, KeyRemovementState>(
          bloc: bloc,
          listener: (context, state) => state.maybeWhen(
            success: () {
              context.router.navigatorKey.currentState?.pop();
            },
            orElse: () => null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CrystalDivider(height: 20),
              Text(
                LocaleKeys.remove_seed_modal_description.tr(),
                style: const TextStyle(
                  fontSize: 16.0,
                  color: CrystalColor.fontDark,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const CrystalDivider(height: 24),
              CrystalButton(
                text: LocaleKeys.remove_seed_modal_actions_remove.tr(),
                onTap: () => bloc.add(KeyRemovementEvent.removeKey(widget.keySubject)),
              ),
            ],
          ),
        ),
      );
}
