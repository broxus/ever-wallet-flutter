import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef TransportTypeBuilder = Widget Function(BuildContext context, bool isEver);

/// Widget that wraps subscribing to stream and provides is ever network or venom network active
class TransportTypeBuilderWidget extends StatelessWidget {
  const TransportTypeBuilderWidget({
    required this.builder,
    super.key,
  });

  final TransportTypeBuilder builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: context.read<TransportRepository>().isEverTransport,
      builder: (context, snapshot) {
        return builder(context, snapshot.data!);
      },
    );
  }
}
