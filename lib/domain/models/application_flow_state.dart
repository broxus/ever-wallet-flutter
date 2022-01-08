import 'package:freezed_annotation/freezed_annotation.dart';

part 'application_flow_state.freezed.dart';

@freezed
class ApplicationFlowState with _$ApplicationFlowState {
  const factory ApplicationFlowState.loading() = _Loading;

  const factory ApplicationFlowState.welcome() = _Welcome;

  const factory ApplicationFlowState.home() = _Home;
}
