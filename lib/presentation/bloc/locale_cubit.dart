import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/locale_repository.dart';

@injectable
class LocaleCubit extends Cubit<Locale?> {
  final LocaleRepository _localeRepository;
  late final StreamSubscription _streamSubscription;

  LocaleCubit(this._localeRepository) : super(_localeRepository.locale?.toLocale()) {
    _streamSubscription = _localeRepository.localeStream.listen((event) => emit(event?.toLocale()));
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  Future<void> setLocale(Locale locale) async {
    await _localeRepository.setLocale(locale.toStringWithSeparator());
    emit(locale);
  }
}

extension LocaleToStringHelper on Locale {
  String toStringWithSeparator({String separator = '_'}) {
    return toString().split('_').join(separator);
  }
}

extension StringToLocaleHelper on String {
  Locale toLocale({String separator = '_'}) {
    final localeList = split(separator);
    switch (localeList.length) {
      case 2:
        return Locale(localeList.first, localeList.last);
      case 3:
        return Locale.fromSubtags(
          languageCode: localeList.first,
          scriptCode: localeList[1],
          countryCode: localeList.last,
        );
      default:
        return Locale(localeList.first);
    }
  }
}
