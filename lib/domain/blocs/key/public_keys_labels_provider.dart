import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection.dart';
import '../../../data/repositories/public_keys_labels_repository.dart';

final publicKeysLabelsProvider =
    StreamProvider<Map<String, String>>((ref) => getIt.get<PublicKeysLabelsRepository>().labelsStream);
