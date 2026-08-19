import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';
import '../../domain/models/models.dart';

class AgentStatusCard extends StatelessWidget {
  final AgentLiveStatus agentStatus;
  final bool isPrimary;
  
  const AgentStatusCard({
    super.key,
    required this.agentStatus,
    this.isPrimary = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final agentType = agentStatus.agentType;
    final state = agentStatus.state;
    final statusColor = agentStatus.statusColor;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: NexusTheme.radiusLarge,
        border: Border.all(
          color: isPrimary ? agentType.badgeColor.withValues(alpha: 0.5) : NexusTheme.white10,
          width: isPrimary ? 2 : 1,
        ),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: agentType.badgeColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                  boxShadow: state.isActive ? [BoxShadow(color: statusColor, blurRadius: 8)] : null,
                ),
              ).animate(target: state.isActive ? 1 : 0).scale(duration: 1000.ms).repeat(),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: agentType.badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: agentType.badgeColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  agentType.title.toUpperCase(),
                  style: NexusTheme.monoTiny.copyWith(
                    color: agentType.badgeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                state.label,
                style: NexusTheme.monoTiny.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Text('CURRENT TASK', style: NexusTheme.monoLabel),
          const SizedBox(height: 4),
          Text(agentStatus.currentTask, style: NexusTheme.monoBody),
          
          const SizedBox(height: 12),
          Text('THOUGHTS', style: NexusTheme.monoLabel),
          const SizedBox(height: 4),
          Text(agentStatus.thoughts, style: NexusTheme.monoSmall.copyWith(color: NexusTheme.white60), maxLines: 2, overflow: TextOverflow.ellipsis),
          
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricChip(icon: Icons.token, label: 'TOKENS', value: agentStatus.activeTokens.toString(), color: NexusTheme.cyan),
              const SizedBox(width: 8),
              _MetricChip(icon: Icons.timer, label: 'LATENCY', value: '${agentStatus.latencyMs}ms', color: NexusTheme.purple),
              const SizedBox(width: 8),
              _MetricChip(icon: Icons.speed, label: 'PROGRESS', value: '${(agentStatus.progress * 100).toInt()}%', color: NexusTheme.emerald),
            ],
          ),
          
          if (isPrimary) ...[
            const SizedBox(height: 16),
            const Divider(color: NexusTheme.white10),
            const SizedBox(height: 12),
            Text('CAPABILITIES', style: NexusTheme.monoLabel),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _getCapabilities(agentType).map((cap) => Chip(
                label: Text(cap, style: NexusTheme.monoTiny),
                backgroundColor: NexusTheme.white05,
                side: BorderSide(color: agentType.badgeColor.withValues(alpha: 0.3)),
                labelStyle: NexusTheme.monoTiny.copyWith(color: agentType.badgeColor),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
  
  List<String> _getCapabilities(AgentType agent) {
    switch (agent) {
      case AgentType.claudeCode(): return ['Architecture', 'Refactoring', 'Code Review', 'System Design', 'ADR Creation'];
      case AgentType.codex(): return ['C++20', 'Rust', 'JNI/NDK', 'SIMD', 'CMake', 'Performance'];
      case AgentType.architect(): return ['Module Graph', 'ADR', 'Patterns', 'Scalability'];
      case AgentType.planner(): return ['Task DAG', 'Decomposition', 'Scheduling', 'Dependencies'];
      case AgentType.devSecOpsSentinel(): return ['SAST', 'DAST', 'MASVS', 'OWASP', 'Auto-fix'];
      case AgentType.performanceAgent(): return ['Profiling', 'Memory', 'SIMD', 'DEX', 'Baseline Profiles'];
      case AgentType.testAgent(): return ['Unit', 'Integration', 'E2E', 'Property-based', 'Regression'];
      case AgentType.reviewerAgent(): return ['Diff Analysis', 'Standards', 'Regression Block', 'Security'];
      case AgentType.releaseAgent(): return ['Changelog', 'Versioning', 'CI/CD', 'Signing', 'Deployment'];
      case AgentType.nativeNdkEngineer(): return ['C++20', 'Rust', 'JNI', 'CMake', 'SIMD', 'ARM64/x86'];
      case AgentType.exaResearcher(): return ['Web Search', 'GitHub', 'Tech Intel', 'Grounding'];
      case AgentType.debugAgent(): return ['Log Parse', 'Stacktrace', 'Hypothesis', 'Root Cause'];
      default: return [];
    }
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 12),
                const SizedBox(width: 4),
                Text(label, style: NexusTheme.monoTiny.copyWith(color: color)),
              ],
            ),
            const SizedBox(height: 2),
            Text(value, style: NexusTheme.monoSmall.copyWith(fontWeight: FontWeight.w600, color: NexusTheme.pureWhite)),
          ],
        ),
      ),
    );
  }
}
