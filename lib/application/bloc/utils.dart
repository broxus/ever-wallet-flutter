import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

EventTransformer<T> debounceSequential<T>(Duration duration) =>
    (events, mapper) => events.debounceTime(duration).asyncExpand(mapper);
