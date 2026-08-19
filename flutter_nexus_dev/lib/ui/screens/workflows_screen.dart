import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';
import '../../ui/viewmodels/main_viewmodel.dart';
import '../../domain/models/models.dart';

class WorkflowsScreen extends StatelessWidget {
  final MainViewModel viewModel;
  
  const WorkflowsScreen({super.key, required this.viewModel});
  
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
                child: _buildQuickActions().animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              ),
              
              SliverToBoxAdapter(
                child: _buildWorkflowsList().animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
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
          Text('WORKFLOWS', style: NexusTheme.monoTitle),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: Text('NEW WORKFLOW', style: NexusTheme.monoTiny),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: NexusTheme.cyan,
              foregroundColor: NexusTheme.oledBlack,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _QuickActionCard(
            icon: Icons.auto_awesome,
            title: 'Autopilot',
            subtitle: 'Full pipeline',
            color: NexusTheme.cyan,
            onTap: () => viewModel.startOrchestration('Production Delivery'),
          )),
          const SizedBox(width: 12),
          Expanded(child: _QuickActionCard(
            icon: Icons.rocket_launch,
            title: 'Deploy',
            subtitle: 'CI/CD Pipeline',
            color: NexusTheme.emerald,
            onTap: () => viewModel.triggerPipeline('Production Deploy', 'PRODUCTION'),
          )),
          const SizedBox(width: 12),
          Expanded(child: _QuickActionCard(
            icon: Icons.security,
            title: 'Security',
            subtitle: 'MASVS Scan',
            color: NexusTheme.amber,
            onTap: () => viewModel.runMasvsStaticAnalysis('CoreAuthService.dart', viewModel.currentAuditedCode.value),
          )),
        ],
      ),
    );
  }
  
  Widget _buildWorkflowsList() {
    final workflows = [
      _MockWorkflow('Full Pipeline', 'COMPLETED', '09:40:55', 'Autopilot Swarm Completo', NexusTheme.emerald),
      _MockWorkflow('Security Audit', 'RUNNING', '09:41:22', 'MASVS v2.0 Compliance', NexusTheme.cyan),
      _MockWorkflow('Performance Opt', 'PENDING', '09:42:00', 'SIMD Optimization', NexusTheme.purple),
      _MockWorkflow('Release Build', 'PENDING', '09:45:00', 'v1.0.0 Release Candidate', NexusTheme.amber),
    ];
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECENT WORKFLOWS', style: NexusTheme.monoLabel),
          const SizedBox(height: 12),
          ...workflows.map((w) => _WorkflowCard(workflow: w)).toList(),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: NexusTheme.radiusMedium,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: NexusTheme.radiusMedium,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: NexusTheme.monoBody.copyWith(fontWeight: FontWeight.w600)),
            Text(subtitle, style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white50)),
          ],
        ),
      ),
    );
  }
}

class _MockWorkflow {
  final String name;
  final String status;
  final String time;
  final String description;
  final Color color;
  
  _MockWorkflow(this.name, this.status, this.time, this.description, this.color);
}

class _WorkflowCard extends StatelessWidget {
  final _MockWorkflow workflow;
  
  const _WorkflowCard({required this.workflow});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: NexusTheme.radiusMedium,
        border: Border.all(color: workflow.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: workflow.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getStatusIcon(workflow.status), color: workflow.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(workflow.name, style: NexusTheme.monoSmall.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: workflow.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(workflow.status, style: NexusTheme.monoTiny.copyWith(color: workflow.color, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                Text(workflow.description, style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white50)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(workflow.time, style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white40)),
              const SizedBox(height: 4),
              IconButton(
                icon: Icon(Icons.more_vert, color: NexusTheme.white30, size: 18),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'RUNNING': return Icons.hourglass_empty;
      case 'COMPLETED': return Icons.check_circle;
      case 'FAILED': return Icons.error;
      default: return Icons.radio_button_unchecked;
    }
  }
}
