import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/nexus_theme.dart';
import '../../ui/viewmodels/main_viewmodel.dart';
import '../components/telemetry_bar.dart';
import '../components/cosmic_radar_scanner.dart';
import '../components/cosmic_resource_gauge.dart';
import '../components/cosmic_starfield_background.dart';

class DashboardScreen extends StatelessWidget {
  final MainViewModel viewModel;
  final VoidCallback onOpenDrawer;
  final VoidCallback onNavigateToWorkflows;
  final VoidCallback onNavigateToAgents;
  final VoidCallback onNavigateToSecurity;
  final VoidCallback onNavigateToTerminal;
  
  const DashboardScreen({
    super.key,
    required this.viewModel,
    required this.onOpenDrawer,
    required this.onNavigateToWorkflows,
    required this.onNavigateToAgents,
    required this.onNavigateToSecurity,
    required this.onNavigateToTerminal,
  });
  
  @override
  Widget build(BuildContext context) {
    return CosmicStarfieldBackground(
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final telemetry = viewModel.telemetry.value;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildAppBar().animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),
              ),
              
              SliverToBoxAdapter(
                child: _buildSystemStatusCard(telemetry).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              ),
              
              SliverToBoxAdapter(
                child: _buildMetricsGrid(telemetry).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              ),
              
              SliverToBoxAdapter(
                child: _buildActivitySection().animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              ),
              
              SliverToBoxAdapter(
                child: _buildResourceUsage(telemetry).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              ),
              
              SliverToBoxAdapter(
                child: _buildRecentWorkflows().animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: NexusTheme.pureWhite, size: 24),
            onPressed: onOpenDrawer,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF0A0A0A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: NexusTheme.white10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('Dashboard', style: NexusTheme.monoTitle),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.volume_up, color: NexusTheme.pureWhite, size: 22),
            onPressed: () => viewModel.speakText('Nexus Dev Orchestrator operational. All agents active.'),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF0A0A0A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: NexusTheme.white10),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSystemStatusCard(TelemetrySnapshot telemetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: NexusTheme.radiusLarge,
          border: Border.all(color: NexusTheme.white10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SYSTEM STATUS', style: NexusTheme.monoLabel),
                  const SizedBox(height: 4),
                  Text('Operational', style: NexusTheme.monoLarge.copyWith(fontSize: 28)),
                  const SizedBox(height: 2),
                  Text(
                    'All systems functioning normally',
                    style: NexusTheme.monoSmall.copyWith(color: NexusTheme.white60),
                  ),
                ],
              ),
            ),
            CosmicRadarScanner(size: 58, radarColor: NexusTheme.cyan),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricsGrid(TelemetrySnapshot telemetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _MetricMiniCard(
            title: 'AGENTS',
            value: '12',
            subLabel: 'Active',
            color: NexusTheme.pureWhite,
            onTap: onNavigateToAgents,
          )),
          const SizedBox(width: 8),
          Expanded(child: _MetricMiniCard(
            title: 'WORKFLOWS',
            value: '8',
            subLabel: 'Running',
            color: NexusTheme.cyan,
            onTap: onNavigateToWorkflows,
          )),
          const SizedBox(width: 8),
          Expanded(child: _MetricMiniCard(
            title: 'CPU',
            value: '${telemetry.cpuPercent.toInt()}%',
            subLabel: 'Usage',
            color: NexusTheme.emerald,
          )),
          const SizedBox(width: 8),
          Expanded(child: _MetricMiniCard(
            title: 'MEMORY',
            value: '${telemetry.memoryUsageMb.toInt()}MB',
            subLabel: 'Used',
            color: NexusTheme.purple,
          )),
        ],
      ),
    );
  }
  
  Widget _buildActivitySection() {
    final activities = [
      _ActivityItem('Security Agent', 'MASVS v2.0 scan completed', '09:41:22', Icons.security, NexusTheme.emerald),
      _ActivityItem('Codex Agent', 'Generated SIMD patch for 3 C++20 files', '09:41:18', Icons.code, NexusTheme.purple),
      _ActivityItem('Claude Agent', 'Analyzing authentication architecture', '09:41:16', Icons.auto_awesome, NexusTheme.cyan),
      _ActivityItem('Exa Research', 'Research completed: 24 sources indexed', '09:41:12', Icons.search, NexusTheme.amber),
      _ActivityItem('Build System', 'NDK compilation successful', '09:41:08', Icons.build, NexusTheme.purple),
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('REAL-TIME ACTIVITY', style: NexusTheme.monoLabel),
              TextButton(
                onPressed: onNavigateToAgents,
                child: Text('VIEW ALL', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.cyan)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...activities.map((a) => _ActivityRow(activity: a)).toList(),
        ],
      ),
    );
  }
  
  Widget _buildResourceUsage(TelemetrySnapshot telemetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: NexusTheme.radiusLarge,
          border: Border.all(color: NexusTheme.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('RESOURCE USAGE', style: NexusTheme.monoLabel),
                TextButton(
                  onPressed: onNavigateToTerminal,
                  child: Text('DETAILS', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.cyan)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CosmicResourceGauge(title: 'CPU', percent: telemetry.cpuPercent.toInt().clamp(15, 95), activeColor: NexusTheme.cyan),
                CosmicResourceGauge(title: 'RAM', percent: 61, activeColor: NexusTheme.purple),
                CosmicResourceGauge(title: 'DISK', percent: 47, activeColor: NexusTheme.emerald),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentWorkflows() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RECENT WORKFLOWS', style: NexusTheme.monoLabel),
              TextButton(
                onPressed: onNavigateToWorkflows,
                child: Text('VIEW ALL', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.cyan)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: NexusTheme.radiusMedium,
              border: Border.all(color: NexusTheme.white10),
            ),
            child: InkWell(
              onTap: onNavigateToWorkflows,
              borderRadius: NexusTheme.radiusMedium,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: NexusTheme.emerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Icon(Icons.rocket_launch, color: NexusTheme.emerald, size: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Full Pipeline', style: NexusTheme.monoBody.copyWith(fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: NexusTheme.emerald, size: 12),
                              const SizedBox(width: 4),
                              Text('Success', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.emerald)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text('09:40:55', style: NexusTheme.monoTiny),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final String subLabel;
  final Color color;
  final VoidCallback? onTap;
  
  const _MetricMiniCard({
    required this.title,
    required this.value,
    required this.subLabel,
    required this.color,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: NexusTheme.radiusMedium,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: NexusTheme.radiusMedium,
          border: Border.all(color: NexusTheme.white10),
        ),
        child: Column(
          children: [
            Text(title, style: NexusTheme.monoTiny),
            const SizedBox(height: 4),
            Text(value, style: NexusTheme.monoTitle.copyWith(fontSize: 18, color: color, fontWeight: FontWeight.w700)),
            Text(subLabel, style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white50)),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem {
  final String agentName;
  final String description;
  final String timestamp;
  final IconData icon;
  final Color accentColor;
  
  _ActivityItem(this.agentName, this.description, this.timestamp, this.icon, this.accentColor);
}

class _ActivityRow extends StatelessWidget {
  final _ActivityItem activity;
  
  const _ActivityRow({required this.activity});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexusTheme.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: activity.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: activity.accentColor.withValues(alpha: 0.3)),
            ),
            child: Icon(activity.icon, color: activity.accentColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.agentName, style: NexusTheme.monoSmall.copyWith(fontWeight: FontWeight.w600)),
                Text(activity.description, style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white60), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(activity.timestamp, style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white40)),
              const SizedBox(height: 4),
              Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: activity.accentColor)),
            ],
          ),
        ],
      ),
    );
  }
}
