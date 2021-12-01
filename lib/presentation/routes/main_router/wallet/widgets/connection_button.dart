import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../../../domain/blocs/connection_bloc.dart';
import '../../../../design/widgets/custom_popup_menu.dart';

class ConnectionButton extends StatelessWidget {
  const ConnectionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<ConnectionBloc, ConnectionData>(
        bloc: context.watch<ConnectionBloc>(),
        builder: (context, state) => CustomPopupMenu(
          items: kNetworkPresets
              .map(
                (e) => Tuple2(
                  e.name,
                  () => context.read<ConnectionBloc>().add(ConnectionEvent.updateTransport(e)),
                ),
              )
              .toList(),
          icon: buildButton(state),
        ),
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
