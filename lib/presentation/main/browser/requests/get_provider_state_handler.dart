import 'dart:async';
import 'dart:convert';

import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../logger.dart';
import '../../../../../data/constants.dart';
import '../../../../../data/repositories/generic_contracts_repository.dart';
import '../../../../../data/repositories/permissions_repository.dart';
import '../../../../../data/repositories/transport_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/extensions.dart';
import '../custom_in_app_web_view_controller.dart';

Future<dynamic> getProviderStateHandler({
  required CustomInAppWebViewController controller,
  required List<dynamic> args,
}) async {
  try {
    final currentOrigin = await controller.controller.getUrl().then((v) => v?.authority);

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
