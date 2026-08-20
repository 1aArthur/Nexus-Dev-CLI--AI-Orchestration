import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/models.dart';
import '../local/local_storage.dart';
import '../repository/terminal_repository.dart';
import '../repository/agent_orchestrator_repository.dart';
import '../repository/devsecops_repository.dart';
import '../repository/exa_search_repository.dart';
import '../repository/cicd_deploy_repository.dart';
import '../audio/tts_service.dart';
import '../audio/grok_voice_service.dart';
import '../security/masvs_static_analyzer.dart';

part 'main_viewmodel.g.dart';

@riverpod
MainViewModel mainViewModel(MainViewModelRef ref) {
  return MainViewModel(ref);
}

class MainViewModel extends ChangeNotifier {
  final Ref _ref;
  late final TerminalRepository _terminalRepository;
  late final AgentOrchestratorRepository _orchestratorRepository;
  late final DevSecOpsRepository _devSecOpsRepository;
  late final ExaSearchRepository _exaRepository;
  late final CicdDeployRepository _cicdRepository;
  late final TtsService _ttsService;
  late final GrokVoiceService _grokVoiceService;
  final ValueNotifier<TelemetrySnapshot> _telemetry = ValueNotifier(TelemetrySnapshot());
  final ValueNotifier<List<TerminalCommandEntity>> _terminalHistory = ValueNotifier([]);
  final ValueNotifier<AgentLiveStatus> _claudeStatus = ValueNotifier(AgentLiveStatus(agentType: AgentType.claudeCode(), state: AgentState.idle(), currentTask: 'Ready for architecture orchestration', thoughts: 'Standing by. Models: gemini-3.1-pro-preview with HIGH Thinking mode.', activeTokens: 1042));
  final ValueNotifier<AgentLiveStatus> _codexStatus = ValueNotifier(AgentLiveStatus(agentType: AgentType.codex(), state: AgentState.idle(), currentTask: 'Ready for C++/Rust/JNI code generation', thoughts: 'Compiler pipeline ready. Native NDK toolchain armed.', activeTokens: 840));
  final ValueNotifier<AutopilotProgress> _autopilotState = ValueNotifier(AutopilotProgress());
  final ValueNotifier<PerformanceMetricsProfile> _performanceProfile = ValueNotifier(PerformanceMetricsProfile());
  final ValueNotifier<String> _customGeminiKey = ValueNotifier('');
  final ValueNotifier<String> _customExaKey = ValueNotifier('');
  final ValueNotifier<String> _customGrokKey = ValueNotifier('');
  final ValueNotifier<List<PipelineStageInfo>> _currentPipelineStages = ValueNotifier([]);
  final ValueNotifier<NativeModuleSpec?> _latestNativeSpec = ValueNotifier(null);
  final ValueNotifier<List<ExaResult>> _exaResults = ValueNotifier([]);
  final ValueNotifier<TerminalShellType> _activeShell = ValueNotifier(TerminalShellType.zsh());
  final ValueNotifier<bool> _isSearchingExa = ValueNotifier(false);
  final ValueNotifier<bool> _isOrchestrating = ValueNotifier(false);
  final ValueNotifier<bool> _isAuditing = ValueNotifier(false);
  final ValueNotifier<bool> _isDeploying = ValueNotifier(false);
  final ValueNotifier<MasvsScanResult?> _masvsScanResult = ValueNotifier(null);
  final ValueNotifier<String> _currentAuditedCode = ValueNotifier(_defaultCodeSnippet);

  ValueNotifier<TelemetrySnapshot> get telemetry => _telemetry;
  ValueNotifier<List<TerminalCommandEntity>> get terminalHistory => _terminalHistory;
  ValueNotifier<AgentLiveStatus> get claudeStatus => _claudeStatus;
  ValueNotifier<AgentLiveStatus> get codexStatus => _codexStatus;
  ValueNotifier<AutopilotProgress> get autopilotState => _autopilotState;
  ValueNotifier<PerformanceMetricsProfile> get performanceProfile => _performanceProfile;
  ValueNotifier<String> get customGeminiKey => _customGeminiKey;
  ValueNotifier<String> get customExaKey => _customExaKey;
  ValueNotifier<String> get customGrokKey => _customGrokKey;
  ValueNotifier<List<PipelineStageInfo>> get currentPipelineStages => _currentPipelineStages;
  ValueNotifier<NativeModuleSpec?> get latestNativeSpec => _latestNativeSpec;
  ValueNotifier<List<ExaResult>> get exaResults => _exaResults;
  ValueNotifier<TerminalShellType> get activeShell => _activeShell;
  ValueNotifier<bool> get isSearchingExa => _isSearchingExa;
  ValueNotifier<bool> get isOrchestrating => _isOrchestrating;
  ValueNotifier<bool> get isAuditing => _isAuditing;
  ValueNotifier<bool> get isDeploying => _isDeploying;
  ValueNotifier<MasvsScanResult?> get masvsScanResult => _masvsScanResult;
  ValueNotifier<String> get currentAuditedCode => _currentAuditedCode;
  ValueNotifier<bool> get isSpeaking => _ttsService.isSpeakingStream as ValueNotifier<bool>;
  ValueNotifier<String> get currentUtterance => _ttsService.utteranceStream as ValueNotifier<String>;
  ValueNotifier<bool> get isGrokConnected => ValueNotifier(_grokVoiceService.isConnected);
  Stream<String> get grokTranscriptStream => _grokVoiceService.transcriptStream;
  Stream<List<int>> get grokAudioStream => _grokVoiceService.audioStream;

  MainViewModel(this._ref) {
    _terminalRepository = _ref.read(terminalRepositoryProvider);
    _orchestratorRepository = _ref.read(agentOrchestratorRepositoryProvider);
    _devSecOpsRepository = _ref.read(devSecOpsRepositoryProvider);
    _exaRepository = _ref.read(exaSearchRepositoryProvider);
    _cicdRepository = _ref.read(cicdDeployRepositoryProvider);
    _ttsService = _ref.read(ttsServiceProvider);
    _grokVoiceService = _ref.read(grokVoiceServiceProvider);
    _init();
  }

  void _init() {
    _startTelemetryHeartbeat();
    _listenToTerminalHistory();
    _listenToTts();
    runMasvsStaticAnalysis('CoreAuthService.dart', _currentAuditedCode.value);
  }

  void _listenToTerminalHistory() {
    _terminalRepository.commandHistoryStream.listen((history) {
      _terminalHistory.value = history;
    });
  }

  void _listenToTts() {
    _ttsService.isSpeakingStream.listen((_) => notifyListeners());
    _ttsService.utteranceStream.listen((_) => notifyListeners());
  }

  void _startTelemetryHeartbeat() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!_telemetry.hasListeners) return false;
      final random = DateTime.now().millisecondsSinceEpoch;
      _telemetry.value = TelemetrySnapshot(cpuPercent: 12.0 + (random % 20).toDouble(), memoryUsageMb: 90.0 + (random % 30).toDouble(), activeThreads: 4 + (random % 6), latencyMs: 30 + (random % 40), totalRequests: _telemetry.value.totalRequests + 1, totalTokens: _telemetry.value.totalTokens + 10 + (random % 35), sessionCostUsd: _telemetry.value.sessionCostUsd + 0.0001);
      return true;
    });
  }

  void setCustomGeminiKey(String key) => _customGeminiKey.value = key.trim();
  void setCustomExaKey(String key) => _customExaKey.value = key.trim();
  void setCustomGrokKey(String key) => _customGrokKey.value = key.trim();
  void updateApiKeys({String? gemini, String? exa, String? grok}) {
    if (gemini != null) _customGeminiKey.value = gemini.trim();
    if (exa != null) _customExaKey.value = exa.trim();
    if (grok != null) { _customGrokKey.value = grok.trim(); _grokVoiceService.setApiKey(grok.trim()); }
  }

  void executeTerminalCommand(String input) {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    final lower = input.trim().toLowerCase();
    if (lower == 'zsh' || lower.startsWith('nx shell zsh')) _activeShell.value = TerminalShellType.zsh();
    else if (lower == 'nu' || lower == 'nushell' || lower.startsWith('nx shell nu')) _activeShell.value = TerminalShellType.nushell();
    else if (lower == 'fish' || lower.startsWith('nx shell fish')) _activeShell.value = TerminalShellType.fish();
    final (tag, output) = _terminalRepository.parseAndGenerateOutput(input, _activeShell.value);
    final duration = DateTime.now().millisecondsSinceEpoch - startTime;
    _terminalRepository.logCommand(command: input, output: output, isError: false, executionTimeMs: duration, agentTag: tag, shellType: _activeShell.value);
    _handleNxCommand(lower, input);
  }

  void _handleNxCommand(String lower, String originalInput) {
    if (lower.startsWith('nx autopilot') || lower == 'autopilot') runAutopilot(originalInput.replaceFirst('nx autopilot', '').replaceFirst('autopilot', '').trim().isEmpty ? 'Production Delivery' : originalInput.replaceFirst('nx autopilot', '').replaceFirst('autopilot', '').trim());
    else if (lower.startsWith('nx debate') || lower.startsWith('debate')) runDebate(originalInput.replaceFirst('nx debate', '').replaceFirst('debate', '').trim().isEmpty ? 'Rust vs C++ NDK SIMD' : originalInput.replaceFirst('nx debate', '').replaceFirst('debate', '').trim());
    else if (lower.startsWith('nx scan') || lower.startsWith('scan') || lower.startsWith('nx security')) runSecurityAudit('CLI Triggered Project', 'val apiKey = "sk-123456789"\nval query = "SELECT * FROM users WHERE id = " + id');
    else if (lower.startsWith('nx performance')) refreshPerformanceProfile();
    else if (lower.startsWith('nx deploy') || lower.startsWith('deploy')) triggerPipeline('CLI CI/CD Auto Deployment', 'PRODUCTION');
    else if (lower.startsWith('nx search') || lower.startsWith('search')) searchExa(originalInput.replaceFirst('nx search', '').replaceFirst('search', '').trim().isEmpty ? 'Android NDK optimizations' : originalInput.replaceFirst('nx search', '').replaceFirst('search', '').trim());
    else if (lower.startsWith('nx voice') || lower.startsWith('voice')) speakText(originalInput.replaceFirst('nx voice', '').replaceFirst('voice', '').trim().isEmpty ? 'Nexus Dev Orchestrator system online.' : originalInput.replaceFirst('nx voice', '').replaceFirst('voice', '').trim());
  }

  void clearTerminal() => _terminalRepository.clearHistory();
  void setActiveShell(TerminalShellType shell) => _activeShell.value = shell;
  void startOrchestration(String goal) {
    if (goal.isEmpty || _isOrchestrating.value) return;
    _isOrchestrating.value = true;
    _orchestratorRepository.runOrchestration(goal: goal, customApiKey: _customGeminiKey.value, onAgentStatusUpdate: (agentType, state, task, thoughts) {
      if (agentType == AgentType.claudeCode()) _claudeStatus.value = _claudeStatus.value.copyWith(state: state, currentTask: task, thoughts: thoughts);
      else if (agentType == AgentType.codex()) _codexStatus.value = _codexStatus.value.copyWith(state: state, currentTask: task, thoughts: thoughts);
      notifyListeners();
    }).then((_) { _isOrchestrating.value = false; notifyListeners(); });
  }
  void runAutopilot(String goal) {
    if (_autopilotState.value.active) return;
    _orchestratorRepository.runAutopilotLoop(goal: goal, customApiKey: _customGeminiKey.value, onProgressUpdate: (progress) { _autopilotState.value = progress; notifyListeners(); }, onAgentStatusUpdate: (agent, state, task, thoughts) {
      if (agent == AgentType.claudeCode()) _claudeStatus.value = _claudeStatus.value.copyWith(state: state, currentTask: task, thoughts: thoughts);
      else if (agent == AgentType.codex()) _codexStatus.value = _codexStatus.value.copyWith(state: state, currentTask: task, thoughts: thoughts);
      notifyListeners();
    });
  }
  void runDebate(String topic) => _orchestratorRepository.runAgentDebate(topic, _customGeminiKey.value);
  void runSecurityAudit(String projectName, String codeSnippet) {
    if (_isAuditing.value) return;
    _isAuditing.value = true;
    _devSecOpsRepository.runSecurityAudit(projectName: projectName.isEmpty ? 'MobileApp Module' : projectName, codeSnippet: codeSnippet, customApiKey: _customGeminiKey.value).then((_) { _isAuditing.value = false; notifyListeners(); });
  }
  void runMasvsStaticAnalysis(String filePath, String codeSnippet) {
    _currentAuditedCode.value = codeSnippet;
    _masvsScanResult.value = MasvsStaticAnalyzer.analyzeSourceCode(filePath, codeSnippet);
    notifyListeners();
  }
  void applyMasvsPatch(SecurityFinding finding) {
    final currentCode = _currentAuditedCode.value;
    if (currentCode.contains(finding.originalSnippet)) {
      final patchedCode = currentCode.replaceAll(finding.originalSnippet, finding.patchSnippet);
      _currentAuditedCode.value = patchedCode;
      runMasvsStaticAnalysis(finding.filePath.isEmpty ? 'CoreAuthService.dart' : finding.filePath, patchedCode);
    }
  }
  void applyAllMasvsPatches() {
    final scan = _masvsScanResult.value;
    if (scan == null) return;
    _currentAuditedCode.value = MasvsStaticAnalyzer.applyVerifiedPatches(_currentAuditedCode.value, scan.findings);
    runMasvsStaticAnalysis(scan.targetName, _currentAuditedCode.value);
  }
  void triggerPipeline(String pipelineName, String targetEnvironment) {
    if (_isDeploying.value) return;
    _isDeploying.value = true;
    _cicdRepository.executePipeline(pipelineName: pipelineName.isEmpty ? 'Nexus Continuous Delivery' : pipelineName, targetEnvironment: targetEnvironment, onStagesUpdate: (stages) { _currentPipelineStages.value = stages; notifyListeners(); }).then((_) { _isDeploying.value = false; notifyListeners(); });
  }
  void generateNativeModule(String moduleName, String methodName, [String language = 'C++20']) {
    _latestNativeSpec.value = _cicdRepository.generateNativeModule(moduleName: moduleName, methodName: methodName, language: language);
    notifyListeners();
  }
  void refreshPerformanceProfile() { _performanceProfile.value = _cicdRepository.generatePerformanceProfile(); notifyListeners(); }
  void searchExa(String query) {
    if (query.isEmpty || _isSearchingExa.value) return;
    _isSearchingExa.value = true;
    _exaRepository.searchExa(query: query, customApiKey: _customExaKey.value).then((results) { _exaResults.value = results; _isSearchingExa.value = false; notifyListeners(); }).catchError((_) { _isSearchingExa.value = false; notifyListeners(); });
  }
  void speakText(String text) { if (text.isEmpty) return; _ttsService.speak(text); }
  void stopSpeaking() => _ttsService.stop();
  Future<void> connectGrokVoice() async { await _grokVoiceService.connect(); notifyListeners(); }
  void disconnectGrokVoice() { _grokVoiceService.disconnect(); notifyListeners(); }
  void sendGrokText(String text) => _grokVoiceService.sendTextMessage(text);
  void sendGrokAudio(List<int> pcmData) => _grokVoiceService.sendAudioChunk(pcmData);
  void commitGrokAudio() => _grokVoiceService.commitAudio();

  @override
  void dispose() {
    _ttsService.dispose();
    _grokVoiceService.dispose();
    super.dispose();
  }
}

static const String _defaultCodeSnippet = '''
class CoreAuthService {
  // Hardcoded secret for test environment (MASVS-STORAGE-1)
  final apiKey = "sk-live-99482180491823abce";
  
  void authenticate(String userId) {
    // Dynamic SQL injection (MASVS-CODE-1)
    final query = "SELECT * FROM users WHERE id = " + userId;
    
    // Insecure file creation mode (MASVS-STORAGE-2)
    // File file = File("session.json").writeAsStringSync("", mode: FileMode.writeOnly);
    
    // Cleartext HTTP endpoint (MASVS-NETWORK-1)
    final endpoint = "http://auth.internal.corp/verify";
    
    // Weak cipher (MASVS-CRYPTO-1)
    // final cipher = Cipher.getInstance("DES");
  }
}
''';
