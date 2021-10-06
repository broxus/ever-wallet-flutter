import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../services/nekoton_service.dart';

part 'provider_events_bloc.freezed.dart';

@injectable
class ProviderEventsBloc extends Bloc<ProviderEventsEvent, ProviderEventsState> {
  final NekotonService _nekotonService;

  ProviderEventsBloc(this._nekotonService) : super(const ProviderEventsState.initial()) {
    _nekotonService.providerDisconnectedStream.listen((event) {
      add(ProviderEventsEvent.onDisconnected(event));
    });

    _nekotonService.providerTransactionsFoundStream.listen((event) {
      add(ProviderEventsEvent.onTransactionsFound(event));
    });

    _nekotonService.providerContractStateChangedStream.listen((event) {
      add(ProviderEventsEvent.onContractStateChanged(event));
    });

    _nekotonService.providerNetworkChangedStream.listen((event) {
      add(ProviderEventsEvent.onNetworkChanged(event));
    });

    _nekotonService.providerPermissionsChangedStream.listen((event) {
      add(ProviderEventsEvent.onPermissionsChanged(event));
    });

    _nekotonService.providerLoggedOutStream.listen((event) {
      add(ProviderEventsEvent.onLoggedOut(event));
    });
  }

  @override
  Stream<ProviderEventsState> mapEventToState(ProviderEventsEvent event) async* {
    yield* event.when(
      onDisconnected: (Error event) async* {
        yield ProviderEventsState.disconnected(event);
      },
      onTransactionsFound: (TransactionsFoundEvent event) async* {
        yield ProviderEventsState.transactionsFound(event);
      },
      onContractStateChanged: (ContractStateChangedEvent event) async* {
        yield ProviderEventsState.contractStateChanged(event);
      },
      onNetworkChanged: (NetworkChangedEvent event) async* {
        yield ProviderEventsState.networkChanged(event);
      },
      onPermissionsChanged: (PermissionsChangedEvent event) async* {
        yield ProviderEventsState.permissionsChanged(event);
      },
      onLoggedOut: (Object event) async* {
        yield ProviderEventsState.loggedOut(event);
      },
    );
  }
}

@freezed
class ProviderEventsEvent with _$ProviderEventsEvent {
  const factory ProviderEventsEvent.onDisconnected(Error event) = _Disconnected;

  const factory ProviderEventsEvent.onTransactionsFound(TransactionsFoundEvent event) = _TransactionsFound;

  const factory ProviderEventsEvent.onContractStateChanged(ContractStateChangedEvent event) = _ContractStateChanged;

  const factory ProviderEventsEvent.onNetworkChanged(NetworkChangedEvent event) = _NetworkChanged;

  const factory ProviderEventsEvent.onPermissionsChanged(PermissionsChangedEvent event) = _PermissionsChanged;

  const factory ProviderEventsEvent.onLoggedOut(Object event) = _LoggedOut;
}

@freezed
class ProviderEventsState with _$ProviderEventsState {
  const factory ProviderEventsState.initial() = _Initial;

  const factory ProviderEventsState.disconnected(Error event) = _OnDisconnected;

  const factory ProviderEventsState.transactionsFound(TransactionsFoundEvent event) = _OnTransactionsFound;

  const factory ProviderEventsState.contractStateChanged(ContractStateChangedEvent event) = _OnContractStateChanged;

  const factory ProviderEventsState.networkChanged(NetworkChangedEvent event) = _OnNetworkChanged;

  const factory ProviderEventsState.permissionsChanged(PermissionsChangedEvent event) = _OnPermissionsChanged;

  const factory ProviderEventsState.loggedOut(Object event) = _OnLoggedOut;
}
