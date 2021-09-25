import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../logger.dart';
import '../../models/connected_site.dart';
import '../../repositories/connected_sites_repository.dart';

part 'connected_sites_bloc.freezed.dart';

@injectable
class ConnectedSitesBloc extends Bloc<_Event, ConnectedSitesState> {
  final ConnectedSitesRepository _connectedSitesRepository;
  final String? address;

  ConnectedSitesBloc(
    this._connectedSitesRepository,
    @factoryParam this.address,
  ) : super(const ConnectedSitesState.initial()) {
    add(const _LocalEvent.updateConnectedSites());
  }

  @override
  Stream<ConnectedSitesState> mapEventToState(_Event event) async* {
    if (event is _LocalEvent) {
      yield* event.when(
        updateConnectedSites: () async* {
          try {
            final connectedSites = await _connectedSitesRepository.getConnectedSites(address!);

            yield ConnectedSitesState.ready(connectedSites);
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield ConnectedSitesState.error(err.toString());
          }
        },
      );
    }

    if (event is ConnectedSitesEvent) {
      yield* event.when(
        addConnectedSite: (String url) async* {
          try {
            final site = ConnectedSite(url: url, time: DateTime.now());
            await _connectedSitesRepository.addConnectedSite(
              address: address!,
              site: site,
            );

            add(const _LocalEvent.updateConnectedSites());
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield ConnectedSitesState.error(err.toString());
          }
        },
        removeConnectedSite: (String url) async* {
          try {
            await _connectedSitesRepository.removeConnectedSite(
              address: address!,
              url: url,
            );

            add(const _LocalEvent.updateConnectedSites());
          } on Exception catch (err, st) {
            logger.e(err, err, st);
            yield ConnectedSitesState.error(err.toString());
          }
        },
      );
    }
  }
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.updateConnectedSites() = _UpdateConnectedSites;
}

@freezed
class ConnectedSitesEvent extends _Event with _$ConnectedSitesEvent {
  const factory ConnectedSitesEvent.addConnectedSite(String url) = _AddConnectedSite;

  const factory ConnectedSitesEvent.removeConnectedSite(String url) = _RemoveConnectedSite;
}

@freezed
class ConnectedSitesState with _$ConnectedSitesState {
  const factory ConnectedSitesState.initial() = _Initial;

  const factory ConnectedSitesState.ready(List<ConnectedSite> connectedSites) = _Ready;

  const factory ConnectedSitesState.error(String info) = _Error;
}
