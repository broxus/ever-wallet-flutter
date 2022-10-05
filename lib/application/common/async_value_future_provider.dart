import 'package:ever_wallet/application/common/async_value.dart';
import 'package:provider/provider.dart';

class AsyncValueFutureProvider<T> extends FutureProvider<AsyncValue<T>> {
  AsyncValueFutureProvider({
    super.key,
    required Create<Future<T>?> create,
    super.lazy,
    super.builder,
    super.child,
  }) : super(
          create: (context) => create.call(context)?.then((value) => AsyncValue.ready(value)),
          initialData: const AsyncValue.loading(),
          catchError: (context, error) => AsyncValue.error(error),
        );
}
