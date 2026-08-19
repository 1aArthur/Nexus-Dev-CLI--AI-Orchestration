import 'package:freezed_annotation/freezed_annotation.dart';

part 'terminal_shell_type.freezed.dart';

@freezed
abstract class TerminalShellType with _$TerminalShellType {
  const factory TerminalShellType.zsh({
    @Default('zsh') String shellName,
    @Default('zsh ❯') String promptPrefix,
    @Default('ZSH') String promptBadge,
    @Default('Default shell • Powerlevel10k & DevOps POSIX workflows') String description,
    @Default(0xFF00F0FF) int tagColorHex,
  }) = ZshShell;

  const factory TerminalShellType.nushell({
    @Default('nushell') String shellName,
    @Default('nu ❯') String promptPrefix,
    @Default('NUSHELL') String promptBadge,
    @Default('Data exploration • Cloud automation & config manipulation') String description,
    @Default(0xFF10B981) int tagColorHex,
  }) = NuShell;

  const factory TerminalShellType.fish({
    @Default('fish') String shellName,
    @Default('fish ❯') String promptPrefix,
    @Default('FISH') String promptBadge,
    @Default('Interactive shell • Instant autosuggestions & syntax highlighting') String description,
    @Default(0xFFF59E0B) int tagColorHex,
  }) = FishShell;
}

extension TerminalShellTypeX on TerminalShellType {
  Color get tagColor => map(
    zsh: (_) => Color(_.tagColorHex),
    nushell: (_) => Color(_.tagColorHex),
    fish: (_) => Color(_.tagColorHex),
  );

  static const List<TerminalShellType> all = [
    TerminalShellType.zsh(),
    TerminalShellType.nushell(),
    TerminalShellType.fish(),
  ];
}
