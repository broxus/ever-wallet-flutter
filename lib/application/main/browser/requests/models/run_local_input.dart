import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

part 'run_local_input.freezed.dart';
part 'run_local_input.g.dart';

@freezed
class RunLocalInput with _$RunLocalInput {
  const factory RunLocalInput({
    required String address,
    FullContractState? cachedState,
    bool? responsible,
    required FunctionCall functionCall,
  }) = _RunLocalInput;

  factory RunLocalInput.fromJson(Map<String, dynamic> json) => _$RunLocalInputFromJson(json);
}
