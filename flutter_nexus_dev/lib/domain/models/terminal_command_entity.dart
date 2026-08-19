import 'package:freezed_annotation/freezed_annotation.dart';
import 'terminal_shell_type.dart';

part 'terminal_command_entity.freezed.dart';
part 'terminal_command_entity.g.dart';

@freezed
abstract class TerminalCommandEntity with _$TerminalCommandEntity {
  const factory TerminalCommandEntity({
    required String id,
    required String command,
    required String output,
    required bool isError,
    required int executionTimeMs,
    required String agentTag,
    required int timestamp,
    @Default(TerminalShellType.zsh()) TerminalShellType shellType,
  }) = _TerminalCommandEntity;

  factory TerminalCommandEntity.fromJson(Map<String, dynamic> json) => _$TerminalCommandEntityFromJson(json);
}
