import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../providers/provider/generic_contracts_state_changes_provider.dart';
import '../../../../providers/provider/generic_contracts_transactions_provider.dart';
import '../../../../providers/provider/logged_out_provider.dart';
import '../../../../providers/provider/network_changes_provider.dart';
import '../../../../providers/provider/permissions_provider.dart';
import '../events/contract_state_changed_handler.dart';
import '../events/logged_out_handler.dart';
import '../events/network_changed_handler.dart';
import '../events/permissions_changed_handler.dart';
import '../events/transactions_found_handler.dart';
import '../extensions.dart';

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
  PermissionsChangedEvent? prevPermissionsChangedEvent;

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue<TransactionsFoundEvent>>(
            genericContractsTransactionsProvider,
            (previous, next) => next.whenData(
              (value) async => transactionsFoundHandler(
                controller: await widget.controller.future,
                event: value,
              ),
            ),
          );

          ref.listen<AsyncValue<ContractStateChangedEvent>>(
            genericContractsStateChangesProvider,
            (previous, next) => next.whenData(
              (value) async => contractStateChangedHandler(
                controller: await widget.controller.future,
                event: value,
              ),
            ),
          );

          ref.listen<AsyncValue<NetworkChangedEvent>>(
            networkChangesProvider,
            (previous, next) => next.whenData(
              (value) async => networkChangedHandler(
                controller: await widget.controller.future,
                event: value,
              ),
            ),
          );

          ref.listen<AsyncValue<List<Tuple2<String, PermissionsChangedEvent>>>>(
            permissionsProvider,
            (previous, next) async => next.whenData((value) async {
              final controller = await widget.controller.future;

              final currentOrigin = await controller.getOrigin();

              final event = value.firstWhereOrNull((e) => e.item1 == currentOrigin)?.item2;

              if (event == null || event == prevPermissionsChangedEvent) return;

              prevPermissionsChangedEvent = event;

              permissionsChangedHandler(
                controller: controller,
                event: event,
              );
            }),
          );

          ref.listen<void>(
            loggedOutProvider,
            (previous, next) async => loggedOutHandler(
              controller: await widget.controller.future,
            ),
          );

          return child!;
        },
        child: widget.child,
      );
}
