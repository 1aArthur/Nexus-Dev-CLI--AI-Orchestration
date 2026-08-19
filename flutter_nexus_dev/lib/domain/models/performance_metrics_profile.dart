import 'package:freezed_annotation/freezed_annotation.dart';

part 'performance_metrics_profile.freezed.dart';
part 'performance_metrics_profile.g.dart';

@freezed
abstract class PerformanceMetricsProfile with _$PerformanceMetricsProfile {
  const factory PerformanceMetricsProfile({
    @Default(14.2) double cpuUtilizationPercent,
    @Default(88.5) double memoryUsageMb,
    @Default(18.4) double apkSizeMb,
    @Default(34210) int dexMethodCount,
    @Default(310) int coldStartTimeMs,
    @Default(85) int warmStartTimeMs,
    @Default(2.1) double gcPauseAverageMs,
    @Default(0.45) double jniBridgeLatencyMicroseconds,
    @Default(4.8) double nativeSimdSpeedup,
    @Default([
      'Enable R8 full mode with shrinkResources to shave ~2.3MB from release APK',
      'Batch native JNI calls in NdkMathAccelerator to reduce JNI boundary transitions',
      'Use Baseline Profiles for Compose startup optimization (<180ms cold start)',
    ]) List<String> recommendations,
  }) = _PerformanceMetricsProfile;

  factory PerformanceMetricsProfile.fromJson(Map<String, dynamic> json) => _$PerformanceMetricsProfileFromJson(json);
}
