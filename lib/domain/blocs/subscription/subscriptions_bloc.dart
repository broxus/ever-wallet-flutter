import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../logger.dart';
import '../../services/nekoton_service.dart';

part 'subscriptions_bloc.freezed.dart';

@injectable
class SubscriptionsBloc extends Bloc<_Event, SubscriptionsState> {
  final NekotonService _nekotonService;
  late final StreamSubscription _streamSubscription;
  final _subscriptions = <SubscriptionSubject>[];
  SubscriptionSubject? _currentSubscription;

  SubscriptionsBloc(this._nekotonService) : super(const SubscriptionsState.initial()) {
    _streamSubscription =
        _nekotonService.subscriptionsStream.listen((event) => add(_LocalEvent.updateSubscriptions(event)));
  }

  @override
  Future<void> close() {
    _streamSubscription.cancel();
    return super.close();
  }

  @override
  Stream<SubscriptionsState> mapEventToState(_Event event) async* {
    if (event is _LocalEvent) {
      yield* event.when(
        updateSubscriptions: (List<SubscriptionSubject> subscriptions) async* {
          try {
            _subscriptions
              ..clear()
              ..addAll(subscriptions);

            final currentSubscription =
                _subscriptions.firstWhereOrNull((e) => e.value.address == _currentSubscription?.value.address);

            if (currentSubscription == null) {
              _currentSubscription = _subscriptions.firstOrNull;
            } else {
              _currentSubscription = currentSubscription;
            }

            yield SubscriptionsState.ready(
              subscriptions: [..._subscriptions],
              currentSubscription: _currentSubscription,
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield SubscriptionsState.error(err.toString());
          }
        },
      );
    }

    if (event is SubscriptionsEvent) {
      yield* event.when(
        setCurrentSubscription: (SubscriptionSubject? subscriptionSubject) async* {
          try {
            _currentSubscription = subscriptionSubject;

            yield SubscriptionsState.ready(
              subscriptions: [..._subscriptions],
              currentSubscription: _currentSubscription,
            );
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield SubscriptionsState.error(err.toString());
          }
        },
      );
    }
  }
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.updateSubscriptions(List<SubscriptionSubject> subscriptions) = _UpdateSubscriptions;
}

@freezed
class SubscriptionsEvent extends _Event with _$SubscriptionsEvent {
  const factory SubscriptionsEvent.setCurrentSubscription(SubscriptionSubject? subscriptionSubject) =
      _SetCurrentSubscription;
}

@freezed
class SubscriptionsState with _$SubscriptionsState {
  const factory SubscriptionsState.initial() = _Initial;

  const factory SubscriptionsState.ready({
    required List<SubscriptionSubject> subscriptions,
    SubscriptionSubject? currentSubscription,
  }) = _Ready;

  const factory SubscriptionsState.error(String info) = _Error;
}
