import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ever_wallet/application/main/browser/events/contract_state_changed_handler.dart';
import 'package:ever_wallet/application/main/browser/events/logged_out_handler.dart';
import 'package:ever_wallet/application/main/browser/events/models/network_changed_event.dart';
import 'package:ever_wallet/application/main/browser/events/models/permissions_changed_event.dart';
import 'package:ever_wallet/application/main/browser/events/network_changed_handler.dart';
import 'package:ever_wallet/application/main/browser/events/permissions_changed_handler.dart';
import 'package:ever_wallet/application/main/browser/events/transactions_found_handler.dart';
import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tuple/tuple.dart';

class EventsListener extends StatefulWidget {
  final Completer<InAppWebViewController> controller;
  final Widget child;

  const EventsListener({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<EventsListener> createState() => _EventsListenerState();
}

class _EventsListenerState extends State<EventsListener> {
  late final StreamSubscription genericContractsTransactionsSubscription;
  late final StreamSubscription genericContractsStateChangesSubscription;
  late final StreamSubscription networkChangesSubscription;
  late final StreamSubscription permissionsSubscription;
  late final StreamSubscription loggedOutSubscription;
  PermissionsChangedEvent? prevPermissionsChangedEvent;

  @override
  void initState() {
    genericContractsTransactionsSubscription =
        context.read<GenericContractsRepository>().tabTransactionsStream(0).listen(
              (event) async => transactionsFoundHandler(
                controller: await widget.controller.future,
                event: event,
              ),
            );

    genericContractsStateChangesSubscription =
        context.read<GenericContractsRepository>().tabStateChangesStream(0).listen(
              (event) async => contractStateChangedHandler(
                controller: await widget.controller.future,
                event: event,
              ),
            );

    networkChangesSubscription = context
        .read<TransportRepository>()
        .transportStream
        .map(
          (e) => NetworkChangedEvent(
            selectedConnection: e.name,
            networkId: e.networkId,
          ),
        )
        .listen(
          (event) async => networkChangedHandler(
            controller: await widget.controller.future,
            event: event,
          ),
        );

    permissionsSubscription = context
        .read<PermissionsRepository>()
        .permissionsStream
        .map(
          (e) => e.entries
              .map(
                (e) => Tuple2(
                  e.key,
                  PermissionsChangedEvent(
                    permissions: e.value,
                  ),
                ),
              )
              .toList(),
        )
        .listen((e) async {
      final controller = await widget.controller.future;

      final currentOrigin = await controller.getOrigin();

      final permissionsChangedEvent = e.firstWhereOrNull((el) => el.item1 == currentOrigin)?.item2;

      if (permissionsChangedEvent == null ||
          permissionsChangedEvent == prevPermissionsChangedEvent) {
        return;
      }

      prevPermissionsChangedEvent = permissionsChangedEvent;

      permissionsChangedHandler(
        controller: controller,
        event: permissionsChangedEvent,
      );
    });

    loggedOutSubscription =
        context.read<KeysRepository>().keysStream.where((e) => e.isEmpty).listen(
              (event) async => loggedOutHandler(
                controller: await widget.controller.future,
              ),
            );
    super.initState();
  }

  @override
  void dispose() {
    genericContractsTransactionsSubscription.cancel();
    genericContractsStateChangesSubscription.cancel();
    networkChangesSubscription.cancel();
    permissionsSubscription.cancel();
    loggedOutSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
