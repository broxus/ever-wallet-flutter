import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/blocs/key/key_export_bloc.dart';
import '../../../../../../injection.dart';
import '../../../design/design.dart';
import '../../router.gr.dart';
import '../widgets/input_password_modal_body.dart';

class ExportSeedPhraseModalBody extends StatefulWidget {
  final String publicKey;

  const ExportSeedPhraseModalBody({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  static String get title => LocaleKeys.export_seed_modal_title.tr();

  @override
  _ExportSeedPhraseModalBodyState createState() => _ExportSeedPhraseModalBodyState();
}

class _ExportSeedPhraseModalBodyState extends State<ExportSeedPhraseModalBody> {
  final bloc = getIt.get<KeyExportBloc>();
  final controller = TextEditingController();

  @override
  void dispose() {
    bloc.close();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<KeyExportBloc, KeyExportState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is KeyExportStateSuccess) {
            context.router.navigatorKey.currentState?.pop();
            context.topRoute.router.navigate(SeedPhraseExportRoute(phrase: state.phrase));
          }
        },
        child: InputPasswordModalBody(
          onSubmit: (password) => bloc.add(
            KeyExportEvent.export(
              publicKey: widget.publicKey,
              password: password,
            ),
          ),
          publicKey: widget.publicKey,
        ),
      );
}
