import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../../../../../domain/blocs/connection_bloc.dart';
import '../../../../design/design.dart';

class ConnectionButton extends StatelessWidget {
  const ConnectionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<ConnectionBloc, ConnectionData>(
        bloc: context.watch<ConnectionBloc>(),
        builder: (context, state) => Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            dividerTheme: const DividerThemeData(color: Colors.grey),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              dividerTheme: const DividerThemeData(color: Colors.grey),
            ),
            child: PopupMenuButton<String>(
              color: CrystalColor.grayBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => kNetworkPresets
                  .map((e) => buildPopupMenuItem(
                        value: e.name,
                        text: e.name,
                      ))
                  .toList()
                  .fold(
                      [],
                      (previousValue, element) => [
                            if (previousValue.isNotEmpty) ...[...previousValue, const PopupMenuDivider()],
                            element
                          ]),
              onSelected: (value) => context
                  .read<ConnectionBloc>()
                  .add(ConnectionEvent.updateTransport(kNetworkPresets.firstWhere((e) => e.name == value))),
              child: buildButton(state),
            ),
          ),
        ),
      );

  Container buildButton(ConnectionData state) => Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.white,
        ),
        child: Text(state.name),
      );

  PopupMenuEntry<String> buildPopupMenuItem({
    required String value,
    required String text,
  }) =>
      PopupMenuItem<String>(
        value: value,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      );
}
