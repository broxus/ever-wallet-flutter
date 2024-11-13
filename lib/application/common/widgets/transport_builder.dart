import 'package:ever_wallet/data/models/connection_data.dart';
import 'package:ever_wallet/data/repositories/transport_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef TransportBuilder = Widget Function(
  BuildContext context,
  ConnectionData data,
);

/// Widget that wraps subscribing to stream and provides is ever network or venom network active
class TransportBuilderWidget extends StatelessWidget {
  const TransportBuilderWidget({
    required this.builder,
    super.key,
  });

  final TransportBuilder builder;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<TransportRepository>();
    return StreamBuilder<ConnectionData>(
      initialData: repository.transportWithData.item2,
      stream: repository.transportWithDataStream.map((event) => event.item2),
      builder: (context, snapshot) {
        return builder(context, snapshot.data!);
      },
    );
  }
}
