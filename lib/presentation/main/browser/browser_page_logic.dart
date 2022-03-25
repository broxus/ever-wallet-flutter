import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mainScriptProvider = FutureProvider.autoDispose(
  (ref) => rootBundle.loadString('packages/nekoton_flutter/assets/js/main.js'),
);

final addressFieldFocusedProvider = StateProvider.autoDispose<bool>((ref) => false);

final backButtonEnabledProvider = StateProvider.autoDispose<bool>((ref) => false);

final forwardButtonEnabledProvider = StateProvider.autoDispose<bool>((ref) => false);

final progressProvider = StateProvider.autoDispose<int>((ref) => 100);

final urlProvider = StateProvider.autoDispose<Uri?>((ref) => null);
