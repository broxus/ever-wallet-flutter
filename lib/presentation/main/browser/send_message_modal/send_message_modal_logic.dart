import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedPublicKeyProvider = StateProvider.autoDispose<String?>((ref) => null);
