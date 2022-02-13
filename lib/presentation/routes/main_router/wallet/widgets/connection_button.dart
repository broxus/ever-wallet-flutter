import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../data/constants.dart';
import '../../../../../data/repositories/transport_repository.dart';
import '../../../../../injection.dart';
import '../../../../../providers/transport_provider.dart';
import '../../../../design/widgets/custom_popup_item.dart';
import '../../../../design/widgets/custom_popup_menu.dart';

class ConnectionButton extends StatelessWidget {
  const ConnectionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final connectionData = ref.watch(transportProvider);

          return connectionData.maybeWhen(
            data: (data) => CustomPopupMenu(
              items: kNetworkPresets
                  .map(
                    (e) => CustomPopupItem(
                      title: Text(
                        e.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () => getIt.get<TransportRepository>().updateTransport(e),
                    ),
                  )
                  .toList(),
              icon: buildButton(data),
            ),
            orElse: () => const SizedBox(),
          );
        },
      );

  Container buildButton(ConnectionData state) => Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.white.withOpacity(0.2),
        ),
        child: Text(
          state.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      );
}
