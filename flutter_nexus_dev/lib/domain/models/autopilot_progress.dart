import 'package:freezed_annotation/freezed_annotation.dart';

part 'autopilot_progress.freezed.dart';
part 'autopilot_progress.g.dart';

@freezed
abstract class AutopilotProgress with _$AutopilotProgress {
  const factory AutopilotProgress({
    @Default(0) int stepIndex,
    @Default(12) int totalSteps,
    @Default('Standby') String currentStep,
    @Default(false) bool active,
    @Default(true) bool buildPass,
    @Default(true) bool testsPass,
    @Default(true) bool securityAcceptable,
    @Default(true) bool lintPass,
    @Default(0) int criticalBugsCount,
    @Default(0) int regressionsCount,
    @Default([]) List<String> logs,
  }) = _AutopilotProgress;

  factory AutopilotProgress.fromJson(Map<String, dynamic> json) => _$AutopilotProgressFromJson(json);
}
