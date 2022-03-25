import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

final selectedAccountProvider = StateProvider.autoDispose<AssetsList?>((ref) => null);
