import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ever_wallet/application/bloc/provider/generic_contracts_state_changes_stream.dart';
import 'package:ever_wallet/application/bloc/provider/generic_contracts_transactions_stream.dart';
import 'package:ever_wallet/application/bloc/provider/logged_out_stream.dart';
import 'package:ever_wallet/application/bloc/provider/network_changes_stream.dart';
import 'package:ever_wallet/application/bloc/provider/permissions_stream.dart';
import 'package:ever_wallet/application/main/browser/events/contract_state_changed_handler.dart';
import 'package:ever_wallet/application/main/browser/events/logged_out_handler.dart';
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

class EventsListener extends StatefulWidget {
  final Completer<InAppWebViewController> controller;
  final Widget child;

  const EventsListener({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

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
        genericContractsTransactionsStream(context.read<GenericContractsRepository>()).listen(
      (event) async => transactionsFoundHandler(
        controller: await widget.controller.future,
        event: event,
      ),
    );

    genericContractsStateChangesSubscription =
        genericContractsStateChangesStream(context.read<GenericContractsRepository>()).listen(
      (event) async => contractStateChangedHandler(
        controller: await widget.controller.future,
        event: event,
      ),
    );

    networkChangesSubscription = networkChangesStream(context.read<TransportRepository>()).listen(
      (event) async => networkChangedHandler(
        controller: await widget.controller.future,
        event: event,
      ),
    );

    permissionsSubscription =
        permissionsStream(context.read<PermissionsRepository>()).listen((event) async {
      final controller = await widget.controller.future;

      final currentOrigin = await controller.getOrigin();

      final permissionsChangedEvent =
          event.firstWhereOrNull((e) => e.item1 == currentOrigin)?.item2;

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

    loggedOutSubscription = loggedOutStream(context.read<KeysRepository>()).listen(
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
