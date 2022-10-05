import 'dart:convert';

import 'package:nekoton_flutter/nekoton_flutter.dart';

String fakeSignature() => base64.encode(List.generate(kSignatureLength, (_) => 0));

String defaultSeedName(int index) => 'Seed $index';
