import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';
import '../../ui/viewmodels/main_viewmodel.dart';
import '../components/agent_status_card.dart';

class AgentMonitorScreen extends StatelessWidget {
  final MainViewModel viewModel;
  
  const AgentMonitorScreen({super.key, required this.viewModel});
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return CosmicStarfieldBackground(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),
              ),
              
              SliverToBoxAdapter(
                child: _buildMainAgents().animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              ),
              
              SliverToBoxAdapter(
                child: _buildAllAgents().animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              ),
              
              if (viewModel.autopilotState.value.active)
                SliverToBoxAdapter(
                  child: _buildAutopilotProgress().animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text('AGENT MONITOR', style: NexusTheme.monoTitle),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: viewModel.isOrchestrating.value ? NexusTheme.cyan.withValues(alpha: 0.2) : NexusTheme.white10,
              borderRadius: NexusTheme.radiusMedium,
              border: Border.all(color: viewModel.isOrchestrating.value ? NexusTheme.cyan : NexusTheme.white10),
            ),
            child: Text(
              viewModel.isOrchestrating.value ? 'ORCHESTRATING' : 'IDLE',
              style: NexusTheme.monoTiny.copyWith(
                color: viewModel.isOrchestrating.value ? NexusTheme.cyan : NexusTheme.white50,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainAgents() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PRIMARY AGENTS', style: NexusTheme.monoLabel),
          const SizedBox(height: 12),
          AgentStatusCard(
            agentStatus: viewModel.claudeStatus.value,
            isPrimary: true,
          ),
          const SizedBox(height: 12),
          AgentStatusCard(
            agentStatus: viewModel.codexStatus.value,
            isPrimary: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAllAgents() {
    final agents = [
      AgentType.planner(),
      AgentType.architect(),
      AgentType.exaResearcher(),
      AgentType.debugAgent(),
      AgentType.devSecOpsSentinel(),
      AgentType.performanceAgent(),
      AgentType.testAgent(),
      AgentType.reviewerAgent(),
      AgentType.releaseAgent(),
      AgentType.nativeNdkEngineer(),
    ];
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SUPPORT AGENTS', style: NexusTheme.monoLabel),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: agents.length,
            itemBuilder: (context, index) {
              final agent = agents[index];
              return _AgentGridCard(agent: agent);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAutopilotProgress() {
    final progress = viewModel.autopilotState.value;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: NexusTheme.radiusLarge,
          border: Border.all(color: NexusTheme.cyan.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: NexusTheme.cyan),
                ).animate().scale(duration: 500.ms).repeat(),
                const SizedBox(width: 8),
                Text('AUTOPILOT ACTIVE', style: NexusTheme.monoLabel.copyWith(color: NexusTheme.cyan)),
                const Spacer(),
                Text('Step ${progress.stepIndex}/${progress.totalSteps}', style: NexusTheme.monoSmall.copyWith(color: NexusTheme.cyan)),
              ],
            ),
            const SizedBox(height: 12),
            Text(progress.currentStep, style: NexusTheme.monoBody),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.stepIndex / progress.totalSteps,
              backgroundColor: NexusTheme.white10,
              valueColor: AlwaysStoppedAnimation<Color>(NexusTheme.cyan),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatusIndicator(label: 'BUILD', passed: progress.buildPass),
                _StatusIndicator(label: 'TESTS', passed: progress.testsPass),
                _StatusIndicator(label: 'SECURITY', passed: progress.securityAcceptable),
                _StatusIndicator(label: 'LINT', passed: progress.lintPass),
              ],
            ),
            if (progress.logs.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('RECENT LOGS', style: NexusTheme.monoLabel),
              const SizedBox(height: 8),
              ...progress.logs.take(3).map((log) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('> $log', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white50)),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class _AgentGridCard extends StatelessWidget {
  final AgentType agent;
  
  const _AgentGridCard({required this.agent});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: NexusTheme.radiusMedium,
        border: Border.all(color: agent.badgeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: agent.badgeColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(agent.title, style: NexusTheme.monoSmall.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(agent.roleDescription, style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white50), maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Text('Model: ${agent.defaultModel}', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white30)),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final bool passed;
  
  const _StatusIndicator({required this.label, required this.passed});
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: passed ? NexusTheme.emerald : NexusTheme.red,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: NexusTheme.monoTiny.copyWith(color: passed ? NexusTheme.emerald : NexusTheme.red, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
