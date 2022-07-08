import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/widgets/custom_popup_item.dart';
import 'package:ever_wallet/application/common/widgets/custom_popup_menu.dart';
import 'package:ever_wallet/data/constants.dart';
import 'package:ever_wallet/data/models/connection_data.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectionButton extends StatelessWidget {
  const ConnectionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamProvider<AsyncValue<ConnectionData>>(
        create: (context) => context
            .read<TransportRepository>()
            .connectionDataStream()
            .map((event) => AsyncValue.ready(event)),
        initialData: const AsyncValue.loading(),
        catchError: (context, error) => AsyncValue.error(error),
        builder: (context, child) {
          final connectionData = context.watch<AsyncValue<ConnectionData>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return connectionData != null
              ? CustomPopupMenu(
                  items: kNetworkPresets
                      .map(
                        (e) => CustomPopupItem(
                          title: Text(
                            e.name,
                            style: const TextStyle(fontSize: 16),
                          ),
                          onTap: () => context.read<TransportRepository>().updateTransport(e),
                        ),
                      )
                      .toList(),
                  icon: buildButton(connectionData.name),
                )
              : const SizedBox();
        },
      );

  Container buildButton(String name) => Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.white.withOpacity(0.2),
        ),
        child: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      );
}
