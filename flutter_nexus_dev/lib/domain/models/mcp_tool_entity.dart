import 'package:freezed_annotation/freezed_annotation.dart';

part 'mcp_tool_entity.freezed.dart';
part 'mcp_tool_entity.g.dart';

@freezed
abstract class McpToolEntity with _$McpToolEntity {
  const factory McpToolEntity({
    required String id,
    required String name,
    required String description,
    required String command,
    required List<String> args,
    @Default({}) Map<String, String> env,
    @Default(true) bool enabled,
    @Default('') String category,
  }) = _McpToolEntity;

  factory McpToolEntity.fromJson(Map<String, dynamic> json) => _$McpToolEntityFromJson(json);
}
