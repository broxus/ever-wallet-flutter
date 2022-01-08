import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final approvalsProvider = StreamProvider<ApprovalRequest>((ref) => getIt.get<NekotonService>().approvalStream);
