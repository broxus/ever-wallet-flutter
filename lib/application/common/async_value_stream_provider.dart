import 'package:ever_wallet/application/common/async_value.dart';
import 'package:provider/provider.dart';

class AsyncValueStreamProvider<T> extends StreamProvider<AsyncValue<T>> {
  AsyncValueStreamProvider({
    super.key,
    required Create<Stream<T>?> create,
    super.lazy,
    super.builder,
    super.child,
  }) : super(
          create: (context) => create.call(context)?.map((event) => AsyncValue.ready(event)),
          initialData: const AsyncValue.loading(),
          catchError: (context, error) => AsyncValue.error(error),
        );
}
