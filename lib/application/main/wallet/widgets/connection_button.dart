import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/widgets/custom_popup_item.dart';
import 'package:ever_wallet/application/common/widgets/custom_popup_menu.dart';
import 'package:ever_wallet/data/models/connection_data.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectionButton extends StatelessWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context) => AsyncValueStreamProvider<ConnectionData>(
        create: (context) => context.read<TransportRepository>().transportStream.map(
              (e) => context
                  .read<TransportRepository>()
                  .networkPresets
                  .firstWhere((el) => el.name == e.name),
            ),
        builder: (context, child) {
          final connectionData = context.watch<AsyncValue<ConnectionData>>().maybeWhen(
                ready: (value) => value,
                orElse: () => null,
              );

          return connectionData != null
              ? CustomPopupMenu(
                  items: context
                      .watch<TransportRepository>()
                      .networkPresets
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
