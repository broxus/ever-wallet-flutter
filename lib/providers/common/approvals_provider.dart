import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/models/approval_request.dart';
import '../../../data/repositories/approvals_repository.dart';
import '../../../injection.dart';
import '../../../logger.dart';

final approvalsProvider = StreamProvider.autoDispose<ApprovalRequest>(
  (ref) => getIt.get<ApprovalsRepository>().approvalsStream.doOnError((err, st) => logger.e(err, err, st)),
);
