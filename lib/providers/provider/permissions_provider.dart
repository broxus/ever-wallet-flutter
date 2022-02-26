import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/repositories/permissions_repository.dart';

final permissionsProvider = StreamProvider<List<Tuple2<String, PermissionsChangedEvent>>>(
  (ref) => getIt
      .get<PermissionsRepository>()
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
      .doOnError((err, st) => logger.e(err, err, st)),
);
