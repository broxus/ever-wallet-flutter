import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/constants.dart';
import '../../../../../data/repositories/generic_contracts_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/transport_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/extensions.dart';
import '../../../../data/models/permission.dart';
import '../../../../data/models/permissions.dart';
import '../extensions.dart';
import 'models/get_provider_state_output.dart';

Future<Map<String, dynamic>> getProviderStateHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('getProviderState', args);

    final origin = await controller.getOrigin();

    final transport = await getIt.get<TransportRepository>().transport;

    const version = kProviderVersion;
    final numericVersion = kProviderVersion.toInt();
    final selectedConnection = transport.connectionData.group;
    const supportedPermissions = Permission.values;
    final permissions = getIt.get<PermissionsRepository>().permissions[origin] ?? const Permissions();
    final subscriptions = getIt.get<GenericContractsRepository>().subscriptions;

    final output = GetProviderStateOutput(
      version: version,
      numericVersion: numericVersion,
      selectedConnection: selectedConnection,
      supportedPermissions: supportedPermissions,
      permissions: permissions,
      subscriptions: subscriptions,
    );

    final jsonOutput = output.toJson();

    return jsonOutput;
  } catch (err, st) {
    logger.e('getProviderState', err, st);
    rethrow;
  }
}
