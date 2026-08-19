import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/nexus_theme.dart';
import '../../ui/viewmodels/main_viewmodel.dart';
import '../components/telemetry_bar.dart';
import '../components/terminal_emulator.dart';
import '../components/audio_waveform_player.dart';

class TerminalScreen extends StatelessWidget {
  final MainViewModel viewModel;
  
  const TerminalScreen({super.key, required this.viewModel});
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Container(
          color: NexusTheme.oledBlack,
          child: Column(
            children: [
              TelemetryBar(telemetry: viewModel.telemetry.value)
                  .animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
              
              if (viewModel.isSpeaking.value)
                AudioWaveformPlayer(
                  isPlaying: viewModel.isSpeaking.value,
                  currentUtterance: viewModel.currentUtterance.value,
                  onStop: viewModel.stopSpeaking,
                ).animate().fadeIn().slideY(begin: 0.2),
              
              Expanded(
                child: TerminalEmulator(
                  history: viewModel.terminalHistory.value,
                  activeShell: viewModel.activeShell.value,
                  onShellChange: viewModel.setActiveShell,
                  onExecuteCommand: viewModel.executeTerminalCommand,
                  onClearTerminal: viewModel.clearTerminal,
                  onNarrateOutput: viewModel.speakText,
                ).animate().fadeIn(delay: 200.ms),
              ),
            ],
          ),
        );
      },
    );
  }
}
