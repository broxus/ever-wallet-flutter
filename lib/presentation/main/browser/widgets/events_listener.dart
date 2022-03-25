import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../providers/provider/generic_contracts_state_changes_provider.dart';
import '../../../../providers/provider/generic_contracts_transactions_provider.dart';
import '../../../../providers/provider/logged_out_provider.dart';
import '../../../../providers/provider/network_changes_provider.dart';
import '../../../../providers/provider/permissions_provider.dart';
import '../custom_in_app_web_view_controller.dart';
import '../events/contract_state_changed_handler.dart';
import '../events/logged_out_handler.dart';
import '../events/network_changed_handler.dart';
import '../events/permissions_changed_handler.dart';
import '../events/transactions_found_handler.dart';

class EventsListener extends StatelessWidget {
  final Completer<CustomInAppWebViewController> controller;
  final Widget child;

  const EventsListener({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          ref.listen<AsyncValue<TransactionsFoundEvent>>(
            genericContractsTransactionsProvider,
            (previous, next) => next.whenData(
              (value) async => transactionsFoundHandler(
                controller: await controller.future,
                event: value,
              ),
            ),
          );

          ref.listen<AsyncValue<ContractStateChangedEvent>>(
            genericContractsStateChangesProvider,
            (previous, next) => next.whenData(
              (value) async => contractStateChangedHandler(
                controller: await controller.future,
                event: value,
              ),
            ),
          );

          ref.listen<AsyncValue<NetworkChangedEvent>>(
            networkChangesProvider,
            (previous, next) => next.whenData(
              (value) async => networkChangedHandler(
                controller: await controller.future,
                event: value,
              ),
            ),
          );

          ref.listen<AsyncValue<List<Tuple2<String, PermissionsChangedEvent>>>>(
            permissionsProvider,
            (previous, next) async => next.whenData((value) async {
              final controller = await this.controller.future;

              final currentOrigin = await controller.controller.getUrl().then((v) => v?.authority);

              final event = value.firstWhereOrNull((e) => e.item1 == currentOrigin)?.item2;

              if (event == null) return;

              permissionsChangedHandler(
                controller: controller,
                event: event,
              );
            }),
          );

          ref.listen<void>(
            loggedOutProvider,
            (previous, next) async => loggedOutHandler(
              controller: await controller.future,
            ),
          );

          return child!;
        },
        child: child,
      );
}
