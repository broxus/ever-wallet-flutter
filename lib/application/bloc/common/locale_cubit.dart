import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ever_wallet/data/repositories/locale_repository.dart';

class LocaleCubit extends Cubit<String?> {
  final LocaleRepository _localeRepository;
  late final StreamSubscription _streamSubscription;

  LocaleCubit(this._localeRepository) : super(_localeRepository.locale) {
    _streamSubscription = _localeRepository.localeStream.listen((event) => emit(event));
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  Future<void> setLocale(String locale) async {
    await _localeRepository.setLocale(locale);
    emit(locale);
  }
}
