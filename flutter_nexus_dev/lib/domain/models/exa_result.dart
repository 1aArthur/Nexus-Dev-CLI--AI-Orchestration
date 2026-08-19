import 'package:freezed_annotation/freezed_annotation.dart';

part 'exa_result.freezed.dart';
part 'exa_result.g.dart';

@freezed
abstract class ExaResult with _$ExaResult {
  const factory ExaResult({
    required String id,
    required String title,
    required String url,
    required String text,
    @Default(0.0) double score,
    @Default('') String publishedDate,
    @Default('') String author,
  }) = _ExaResult;

  factory ExaResult.fromJson(Map<String, dynamic> json) => _$ExaResultFromJson(json);
}
