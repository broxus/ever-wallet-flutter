import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/constants.dart';
import '../../../../../data/repositories/generic_contracts_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/transport_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/extensions.dart';
import '../extensions.dart';

Future<dynamic> getProviderStateHandler({
  required InAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    logger.d('GetProviderStateRequest', args);

    final currentOrigin = await controller.getOrigin();

    if (currentOrigin == null) throw Exception();

    final transport = await getIt.get<TransportRepository>().transport;

    const version = kProviderVersion;
    final numericVersion = kProviderVersion.toInt();
    final selectedConnection = transport.connectionData.name;
    const supportedPermissions = Permission.values;
    final permissions = getIt.get<PermissionsRepository>().permissions[currentOrigin] ?? const Permissions();
    final subscriptions = getIt.get<GenericContractsRepository>().subscriptions;

    final output = GetProviderStateOutput(
      version: version,
      numericVersion: numericVersion,
      selectedConnection: selectedConnection,
      supportedPermissions: supportedPermissions,
      permissions: permissions,
      subscriptions: subscriptions,
    );

    final jsonOutput = jsonEncode(output.toJson());

    return jsonOutput;
  } catch (err, st) {
    logger.e(err, err, st);
  }
}
