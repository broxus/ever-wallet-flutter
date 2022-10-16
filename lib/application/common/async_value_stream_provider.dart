import 'package:ever_wallet/application/common/async_value.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AsyncValueStreamProvider<T> extends StatelessWidget {
  const AsyncValueStreamProvider({
    super.key,
    required this.create,
    this.lazy,
    this.builder,
    this.child,
    this.updateShouldNotify,
  });

  final Create<Stream<T>?> create;
  final UpdateShouldNotify<AsyncValue<T>>? updateShouldNotify;
  final bool? lazy;
  final TransitionBuilder? builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return StreamProvider<AsyncValue<T>>(
      create: (context) => create.call(context)?.map((event) => AsyncValue.ready(event)),
      initialData: const AsyncValue.loading(),
      catchError: (context, error) => AsyncValue.error(error),
      builder: builder,
      lazy: lazy,
      updateShouldNotify: updateShouldNotify,
      child: child,
    );
  }
}
