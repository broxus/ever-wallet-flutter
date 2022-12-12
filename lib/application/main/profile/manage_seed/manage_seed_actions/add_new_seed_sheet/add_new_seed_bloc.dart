import 'package:bloc/bloc.dart';
import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'add_new_seed_bloc.freezed.dart';

/// Bloc with basic state machine and linear logic of navigation.
/// initial -> save -> validate -> password
/// initial -> import -> password
///
/// Bloc supports stack of navigation to allow restore it with back navigation.
/// If state is saved to stack, it is filled with data it had been entered with
class AddNewSeedBloc extends Bloc<AddNewSeedBlocEvent, AddNewSeedBlocState> {
  final VoidCallback completeFlow;
  final KeysRepository keysRepository;

  AddNewSeedBloc(this.completeFlow, this.keysRepository)
      : super(const AddNewSeedBlocState.initial(null, null)) {
    on<_InitialEvent>((event, emit) {
      _enteredName = event.name;
      _enteredType = event.type;
      _saveStateToCache(state);
      switch (event.type) {
        case AddNewSeedType.create:
          _enteredPhrase = generateKey(kDefaultMnemonicType).words;
          emit(AddNewSeedBlocState.saveSeed(_enteredPhrase!));
          break;
        case AddNewSeedType.import:
          emit(const AddNewSeedBlocState.importSeed(null, false));
          break;
        case AddNewSeedType.importLegacy:
          emit(const AddNewSeedBlocState.importSeed(null, true));
          break;
      }
    });
    on<_SeedSaved>((event, emit) {
      _saveStateToCache(state);
      emit(AddNewSeedBlocState.validateSeed(_enteredPhrase!));
    });
    on<_SeedValidated>((event, emit) {
      _saveStateToCache(state);
      emit(const AddNewSeedBlocState.enterPassword());
    });
    on<_ImportSeedEvent>((event, emit) {
      _enteredPhrase = event.phrase;
      _saveStateToCache(state);
      emit(const AddNewSeedBlocState.enterPassword());
    });
    on<_ConfirmPassword>((event, emit) async {
      await keysRepository.createKey(
        name: _enteredName,
        phrase: _enteredPhrase!,
        password: event.password.trim(),
      );

      completeFlow();
    });
    on<_PrevState>((event, emit) => emit(_stateStack.removeLast()));
  }

  /// Stack of states to be able navigate back
  final _stateStack = <AddNewSeedBlocState>[];

  /// Cache of values
  String? _enteredName;
  List<String>? _enteredPhrase;
  AddNewSeedType? _enteredType;

  void _saveStateToCache(AddNewSeedBlocState state) {
    if (state is _Initial) {
      _stateStack.add(state.copyWith(name: _enteredName, type: _enteredType));
    } else if (state is _SaveSeed) {
      _stateStack.add(state.copyWith(phrase: _enteredPhrase!));
    } else if (state is _ValidateSeed) {
      _stateStack.add(state.copyWith(phrase: _enteredPhrase!));
    } else if (state is _ImportSeed) {
      _stateStack.add(state.copyWith(phrase: _enteredPhrase));
    }
  }
}

@freezed
class AddNewSeedBlocState with _$AddNewSeedBlocState {
  /// Starting state where user should enter seed name and select type of creation
  const factory AddNewSeedBlocState.initial(String? name, AddNewSeedType? type) = _Initial;

  /// User see save seed screen
  const factory AddNewSeedBlocState.saveSeed(List<String> phrase) = _SaveSeed;

  /// User must validate saved phrase
  const factory AddNewSeedBlocState.validateSeed(List<String> phrase) = _ValidateSeed;

  /// User wants to import external seed phrase
  const factory AddNewSeedBlocState.importSeed(List<String>? phrase, bool isLegacy) = _ImportSeed;

  /// User must enter password when name and seed are entered to finish adding new seed
  const factory AddNewSeedBlocState.enterPassword() = _EnterPassword;
}

@freezed
class AddNewSeedBlocEvent with _$AddNewSeedBlocEvent {
  /// User entered seed name and selected type of creation
  /// Current state: initial
  /// Next states: saveSeed or importSeed
  const factory AddNewSeedBlocEvent.enterName(String name, AddNewSeedType type) = _InitialEvent;

  /// User wrote down seed phrase
  /// Current state: saveSeed
  /// Next state: validateSeed
  const factory AddNewSeedBlocEvent.seedSaved() = _SeedSaved;

  /// User validated seed correctly
  /// Current state: validateSeed
  /// Next state: enterPassword
  const factory AddNewSeedBlocEvent.seedValidated() = _SeedValidated;

  /// User entered seed phrase
  /// Current state: importSeed
  /// Next state: enterPassword
  const factory AddNewSeedBlocEvent.importSeed(List<String> phrase) = _ImportSeedEvent;

  /// User entered password to complete flow
  /// Current state: enterPassword
  /// Next state: end of state machine
  const factory AddNewSeedBlocEvent.confirmPassword(String password) = _ConfirmPassword;

  /// User pressed back button, show prev state from stack. UI must know where is possible to pop state
  /// Current state: any state
  /// Next state: last state from stack
  const factory AddNewSeedBlocEvent.prevState() = _PrevState;
}

enum AddNewSeedType {
  create,
  import,
  importLegacy,
}
