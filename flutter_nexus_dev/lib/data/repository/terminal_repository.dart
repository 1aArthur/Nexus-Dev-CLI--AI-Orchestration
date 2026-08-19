import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/models.dart';
import '../local/local_storage.dart';

part 'terminal_repository.g.dart';

@riverpod
TerminalRepository terminalRepository(TerminalRepositoryRef ref) {
  return TerminalRepository(ref.read(terminalHistoryBoxProvider));
}

class TerminalRepository {
  final Box<TerminalCommandEntity> _box;
  
  TerminalRepository(this._box);
  
  Stream<List<TerminalCommandEntity>> get commandHistoryStream => _box.watch().map((_) => _getAllCommands());
  
  List<TerminalCommandEntity> _getAllCommands() {
    return _box.values.toList().reversed.toList();
  }
  
  Future<void> logCommand({
    required String command,
    required String output,
    required bool isError,
    required int executionTimeMs,
    required String agentTag,
    required TerminalShellType shellType,
  }) async {
    final entity = TerminalCommandEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      command: command,
      output: output,
      isError: isError,
      executionTimeMs: executionTimeMs,
      agentTag: agentTag,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      shellType: shellType,
    );
    await _box.add(entity);
  }
  
  Future<void> clearHistory() async {
    await _box.clear();
  }
  
  (String tag, String output) parseAndGenerateOutput(String input, TerminalShellType shellType) {
    final lower = input.trim().toLowerCase();
    
    if (lower.isEmpty) {
      return ('', '');
    }
    
    switch (lower) {
      case 'help':
        return ('SHELL', _getHelpText(shellType));
      case 'clear':
        return ('SHELL', 'CLEAR_TERMINAL');
      case 'ls':
      case 'dir':
        return ('SHELL', _getLsOutput());
      case 'pwd':
        return ('SHELL', '/data/user/0/com.nexus.dev.orchestrator');
      case 'whoami':
        return ('SHELL', 'nexus-dev@android');
      case 'date':
        return ('SHELL', DateTime.now().toIso8601String());
      case 'ps':
        return ('SHELL', _getPsOutput());
      case 'top':
        return ('SHELL', _getTopOutput());
      case 'df':
        return ('SHELL', _getDfOutput());
      case 'free':
        return ('SHELL', _getFreeOutput());
      case 'env':
        return ('SHELL', _getEnvOutput());
      case 'history':
        return ('SHELL', _getHistoryOutput());
    }
    
    if (lower.startsWith('nx ')) {
      return _parseNxCommand(lower.substring(3));
    }
    
    return _simulateCommand(input, shellType);
  }
  
  String _getHelpText(TerminalShellType shellType) {
    return '''
Nexus Dev Orchestrator Terminal v1.0
Shell: ${shellType.shellName.toUpperCase()}

BUILT-IN COMMANDS:
  help           Show this help
  clear          Clear terminal
  ls, dir        List directory
  pwd            Print working directory
  whoami         Current user
  date           Current date/time
  ps             Process list
  top            System monitor
  df             Disk usage
  free           Memory usage
  env            Environment variables
  history        Command history

NX COMMANDS:
  nx autopilot [goal]    Run full autopilot
  nx debate [topic]      Agent debate
  nx scan [target]       Security scan
  nx deploy [env]        Deploy pipeline
  nx search [query]      Exa web search
  nx voice [text]        Speak text
  nx performance         Refresh performance
  nx build               Build project
  nx test                Run tests
  nx lint                Run linter

SHELL-SPECIFIC:
  zsh           Switch to Zsh
  nushell       Switch to NuShell
  fish          Switch to Fish

Type any command to execute. Use TAB for completion.
''';
  }
  
  String _getLsOutput() {
    return '''drwxr-xr-x  2 nexus  nexus  4096 Aug 19 12:00 app
drwxr-xr-x  3 nexus  nexus  4096 Aug 19 12:00 lib
drwxr-xr-x  2 nexus  nexus  4096 Aug 19 12:00 test
-rw-r--r--  1 nexus  nexus   512 Aug 19 12:00 pubspec.yaml
-rw-r--r--  1 nexus  nexus  2048 Aug 19 12:00 README.md
-rw-r--r--  1 nexus  nexus  1024 Aug 19 12:00 LICENSE''';
  }
  
  String _getPsOutput() {
    return '''  PID  PPID  NAME
    1     0    init
  123     1    zygote
  456   123    system_server
  789   123    com.nexus.dev.orchestrator
 1024   789    nexus.orchestrator
 1025   789    nexus.terminal
 1026   789    nexus.audio''';
  }
  
  String _getTopOutput() {
    return '''CPU: 12.4%  MEM: 94.2MB  Threads: 8
  PID    CPU%   MEM%   NAME
  789    5.2%   45.1%  nexus.orchestrator
 1024    2.1%   12.3%  nexus.terminal
 1025    1.8%    8.7%  nexus.audio
 1026    0.5%    3.2%  nexus.network''';
  }
  
  String _getDfOutput() {
    return '''Filesystem     1K-blocks    Used  Available Use% Mounted on
/dev/block/dm-0   10485760  4194304   6291456  40% /
/dev/block/dm-1    5242880  1048576   4194304  20% /data''';
  }
  
  String _getFreeOutput() {
    return '''              total        used        free      shared  buff/cache   available
Mem:         8388608      94208      725400       12048     8194352     8123456
Swap:             0           0           0''';
  }
  
  String _getEnvOutput() {
    return '''ANDROID_ROOT=/system
ANDROID_DATA=/data
ANDROID_STORAGE=/storage
EXTERNAL_STORAGE=/sdcard
PATH=/system/bin:/system/xbin
SHELL=/system/bin/sh
HOME=/data/user/0/com.nexus.dev.orchestrator
NEXUS_VERSION=1.0.0
NEXUS_SHELL=zsh''';
  }
  
  String _getHistoryOutput() {
    final commands = _getAllCommands().take(20).toList();
    if (commands.isEmpty) return 'No history';
    return commands.asMap().entries.map((e) => '${e.key + 1}  ${e.value.command}').join('\n');
  }
  
  (String, String) _parseNxCommand(String cmd) {
    final parts = cmd.trim().split(' ');
    final action = parts.isNotEmpty ? parts[0] : '';
    final args = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    
    switch (action) {
      case 'autopilot':
        return ('ORCHESTRATOR', 'Autopilot initiated: ${args.isEmpty ? "Production Delivery" : args}\n[AGENTS] Planner, Architect, Claude Code, Codex, DevSecOps, Performance, Test, Reviewer, Release, Native NDK\n[STATUS] DAG generated. Concurrent execution started.\n[ETA] ~3 minutes');
      case 'debate':
        return ('DEBATE', 'Agent Debate: ${args.isEmpty ? "Rust vs C++ NDK SIMD" : args}\n[CLAUDE] Architecture favors Rust for memory safety\n[CODEX] C++20 SIMD intrinsics give 4.8x speedup\n[EVALUATOR] Convergence: 94% - Hybrid approach recommended');
      case 'scan':
        return ('DEVSECOPS', 'Security Scan: ${args.isEmpty ? "Full Project" : args}\n[MASVS] Scanning STORAGE, CRYPTO, NETWORK, CODE, PLATFORM\n[SCA] Checking dependencies for CVEs\n[SAST] Static analysis complete\n[RESULT] 3 Critical, 5 High, 8 Medium, 12 Low');
      case 'deploy':
        return ('CICD', 'Deployment: ${args.isEmpty ? "PRODUCTION" : args}\n[STAGES] Build → Test → Security → Sign → Deploy\n[STATUS] Pipeline triggered\n[ETA] ~5 minutes');
      case 'search':
        return ('EXA', 'Exa Search: ${args.isEmpty ? "Android NDK optimizations" : args}\n[RESULTS] 24 sources indexed\n[TOP] SIMD intrinsics, Baseline Profiles, R8 optimization');
      case 'voice':
        return ('AUDIO', 'Speaking: ${args.isEmpty ? "Nexus Dev Orchestrator system online" : args}');
      case 'performance':
        return ('PERFORMANCE', 'Performance Profile Refreshed\n[CPU] 14.2%  [MEM] 88.5MB  [APK] 18.4MB\n[COLD START] 310ms  [WARM] 85ms\n[SIMD SPEEDUP] 4.8x');
      case 'build':
        return ('BUILD', 'Building...\n[COMPILE] Dart → AOT\n[LINK] Native libraries\n[PACKAGE] APK/AAB\n[SUCCESS] Build complete in 45s');
      case 'test':
        return ('TEST', 'Running tests...\n[UNIT] 247 passed\n[INTEGRATION] 12 passed\n[E2E] 8 passed\n[COVERAGE] 87%');
      case 'lint':
        return ('LINT', 'Linting...\n[DART] 0 errors, 3 warnings\n[RUST] 0 errors\n[C++] 0 errors\n[CLEAN] Code style verified');
      default:
        return ('NX', 'Unknown nx command: $action\nType "nx help" for available commands');
    }
  }
  
  (String, String) _simulateCommand(String input, TerminalShellType shellType) {
    final prompt = shellType.promptPrefix;
    return ('CMD', '$prompt $input\n[SIMULATED] Command executed in ${shellType.shellName}');
  }
}
