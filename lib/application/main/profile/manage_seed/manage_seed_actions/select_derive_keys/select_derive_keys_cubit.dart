import 'package:bloc/bloc.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'select_derive_keys_cubit.freezed.dart';

class SelectDeriveKeysCubit extends Cubit<SelectDeriveKeysCubitState> {
  static const countPerPage = 5;

  final Keystore _keystore;
  final KeyStoreEntry key;
  final String _password;
  final KeysRepository _keysRepository;

  final VoidCallback onFinish;

  SelectDeriveKeysCubit(
    this.key,
    this._password,
    this._keystore,
    this._keysRepository,
    this.onFinish,
  ) : super(const SelectDeriveKeysCubitState.init()) {
    _init();
  }

  final publicKeys = <String>[];
  final selectedKeys = <String>[];

  /// List of addresses that were added earlier
  final initialKeys = <String>[];

  int displayPage = 0;

  bool get canPrevPage => displayPage > 0;

  bool get canNextPage => displayPage - 1 < publicKeys.length ~/ countPerPage;

  Future<void> _init() async {
    final adr = await _keystore.getPublicKeys(
      DerivedKeyGetPublicKeys(
        masterKey: key.publicKey,
        offset: 0,
        limit: 20,
        password: Password.explicit(
          PasswordExplicit(
            password: _password,
            cacheBehavior: const PasswordCacheBehavior.nop(),
          ),
        ),
      ),
    );
    publicKeys.addAll(adr);
    final subKeys = _keysRepository.keys.where((k) => k.masterKey == key.publicKey);
    initialKeys.addAll(subKeys.map((e) => e.publicKey));

    emit(
      SelectDeriveKeysCubitState.display(
        keys: List.from(publicKeys),
        selected: List.from(selectedKeys),
        initial: List.from(initialKeys),
        page: displayPage,
      ),
    );
  }

  void toggleAddress(String address) {
    if (selectedKeys.contains(address)) {
      selectedKeys.remove(address);
    } else {
      selectedKeys.add(address);
    }

    emit(
      SelectDeriveKeysCubitState.display(
        keys: List.from(publicKeys),
        selected: List.from(selectedKeys),
        initial: List.from(initialKeys),
        page: displayPage,
      ),
    );
  }

  /// sign = 1 or -1
  void movePage(int sign) {
    displayPage += sign;
    emit(
      SelectDeriveKeysCubitState.display(
        keys: List.from(publicKeys),
        selected: List.from(selectedKeys),
        initial: List.from(initialKeys),
        page: displayPage,
      ),
    );
  }

  Future<void> selectAll() async {
    if (selectedKeys.isNotEmpty) {
      emit(
        SelectDeriveKeysCubitState.creating(
          keys: publicKeys,
          selected: selectedKeys,
          initial: initialKeys,
          page: displayPage,
        ),
      );
      for (final k in selectedKeys) {
        await _keysRepository.deriveKey(
          masterKey: key.publicKey,
          accountId: publicKeys.indexOf(k),
          password: _password,
        );
      }
      onFinish();
    }
  }
}

@freezed
class SelectDeriveKeysCubitState with _$SelectDeriveKeysCubitState {
  /// Loading keys
  const factory SelectDeriveKeysCubitState.init() = _Init;

  /// Common state
  const factory SelectDeriveKeysCubitState.display({
    required List<String> keys,
    required List<String> selected,
    required List<String> initial,
    required int page,
  }) = _Display;

  /// Block button and display loading indicator
  const factory SelectDeriveKeysCubitState.creating({
    required List<String> keys,
    required List<String> selected,
    required List<String> initial,
    required int page,
  }) = _Creating;
}
