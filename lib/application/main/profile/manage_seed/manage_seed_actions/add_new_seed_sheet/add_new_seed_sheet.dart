import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_new_seed_sheet/add_new_seed_bloc.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_new_seed_sheet/widgets/add_new_seed_import_widget.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_new_seed_sheet/widgets/add_new_seed_initial_widget.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_new_seed_sheet/widgets/add_new_seed_password_widget.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_new_seed_sheet/widgets/add_new_seed_save_widget.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/add_new_seed_sheet/widgets/add_new_seed_validate_widget.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewSeedSheet extends StatefulWidget {
  const AddNewSeedSheet({
    super.key,
  });

  @override
  State<AddNewSeedSheet> createState() => _AddNewSeedSheetState();
}

class _AddNewSeedSheetState extends State<AddNewSeedSheet> {
  late AddNewSeedBloc bloc = AddNewSeedBloc(_closeSheet, context.read<KeysRepository>());

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: BlocBuilder<AddNewSeedBloc, AddNewSeedBlocState>(
          bloc: bloc,
          builder: (context, state) {
            return state.when<Widget>(
              initial: _initialState,
              saveSeed: _saveSeedState,
              validateSeed: _validateSeedState,
              importSeed: _importSeedState,
              enterPassword: _enterPasswordState,
            );
          },
        ),
      ),
    );
  }

  Widget _initialState(String? name, AddNewSeedType? type) => AddNewSeedInitialWidget(
        action: (name, type) => bloc.add(AddNewSeedBlocEvent.enterName(name, type)),
        savedName: name,
        savedType: type,
      );

  Widget _saveSeedState(List<String> phrase) => AddNewSeedSaveWidget(
        backAction: () => bloc.add(const AddNewSeedBlocEvent.prevState()),
        nextAction: () => bloc.add(const AddNewSeedBlocEvent.seedSaved()),
        phrase: phrase,
      );

  Widget _validateSeedState(List<String> phrase) => AddNewSeedValidateWidget(
        backAction: () => bloc.add(const AddNewSeedBlocEvent.prevState()),
        nextAction: () => bloc.add(const AddNewSeedBlocEvent.seedValidated()),
        phrase: phrase,
      );

  Widget _importSeedState(List<String>? phrase) => AddNewSeedImportWidget(
        backAction: () => bloc.add(const AddNewSeedBlocEvent.prevState()),
        savedPhrase: phrase,
        onPhraseEntered: (phrase) => bloc.add(AddNewSeedBlocEvent.importSeed(phrase)),
      );

  Widget _enterPasswordState() => AddNewSeedPasswordWidget(
        backAction: () => bloc.add(const AddNewSeedBlocEvent.prevState()),
        nextAction: (password) => bloc.add(AddNewSeedBlocEvent.confirmPassword(password)),
      );

  void _closeSheet() => Navigator.of(context).pop();
}
