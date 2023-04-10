import 'dart:async';

import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/application/main/browser/requests/models/get_provider_state_output.dart';
import 'package:ever_wallet/data/extensions.dart';
import 'package:ever_wallet/data/models/permission.dart';
import 'package:ever_wallet/data/models/permissions.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';
import 'package:ever_wallet/data/repositories/permissions_repository.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

Future<Map<String, dynamic>> getProviderStateHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
  required int tabId,
  required PermissionsRepository permissionsRepository,
  required TransportRepository transportRepository,
  required GenericContractsRepository genericContractsRepository,
}) async {
  try {
    logger.d('getProviderState', args);

    final origin = await controller.getOrigin();

    final transport = transportRepository.transport;

    const version = kProviderVersion;
    final numericVersion = kProviderVersion.toInt();
    final selectedConnection = transport.group;
    const supportedPermissions = Permission.values;
    final permissions = permissionsRepository.permissions[origin] ?? const Permissions();
    final subscriptions = genericContractsRepository.tabSubscriptions(tabId);
    final networkId = await transport.getNetworkId();

    final output = GetProviderStateOutput(
      version: version,
      numericVersion: numericVersion,
      networkId: networkId,
      selectedConnection: selectedConnection,
      supportedPermissions: supportedPermissions,
      permissions: permissions,
      subscriptions: subscriptions ?? {},
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('getProviderState', err, st);
    rethrow;
  }
}
