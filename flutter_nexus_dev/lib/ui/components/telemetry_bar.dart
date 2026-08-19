import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';
import '../../domain/models/models.dart';

class TelemetryBar extends StatelessWidget {
  final TelemetrySnapshot telemetry;
  
  const TelemetryBar({super.key, required this.telemetry});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF050505),
        border: Border(bottom: BorderSide(color: NexusTheme.white10)),
      ),
      child: Row(
        children: [
          _TelemetryItem(
            icon: Icons.speed,
            label: 'CPU',
            value: '${telemetry.cpuPercent.toStringAsFixed(1)}%',
            color: NexusTheme.cyan,
            trend: _getCpuTrend(),
          ),
          _TelemetryItem(
            icon: Icons.memory,
            label: 'RAM',
            value: '${telemetry.memoryUsageMb.toStringAsFixed(0)}MB',
            color: NexusTheme.purple,
            trend: _getMemoryTrend(),
          ),
          _TelemetryItem(
            icon: Icons.cloud_queue,
            label: 'THREADS',
            value: telemetry.activeThreads.toString(),
            color: NexusTheme.emerald,
            trend: _getThreadTrend(),
          ),
          _TelemetryItem(
            icon: Icons.timer,
            label: 'LATENCY',
            value: '${telemetry.latencyMs}ms',
            color: NexusTheme.amber,
            trend: _getLatencyTrend(),
          ),
          _TelemetryItem(
            icon: Icons.request_page,
            label: 'REQ',
            value: telemetry.totalRequests.toString(),
            color: NexusTheme.purple,
            trend: null,
          ),
          _TelemetryItem(
            icon: Icons.token,
            label: 'TOKENS',
            value: _formatTokens(telemetry.totalTokens),
            color: NexusTheme.cyan,
            trend: null,
          ),
          _TelemetryItem(
            icon: Icons.attach_money,
            label: 'COST',
            value: '\$${telemetry.sessionCostUsd.toStringAsFixed(4)}',
            color: NexusTheme.emerald,
            trend: null,
          ),
        ],
      ),
    );
  }
  
  String _formatTokens(int tokens) {
    if (tokens >= 1000000) return '${(tokens / 1000000).toStringAsFixed(1)}M';
    if (tokens >= 1000) return '${(tokens / 1000).toStringAsFixed(1)}K';
    return tokens.toString();
  }
  
  String? _getCpuTrend() => (telemetry.cpuPercent > 50) ? '▲' : (telemetry.cpuPercent < 20) ? '▼' : '●';
  String? _getMemoryTrend() => (telemetry.memoryUsageMb > 200) ? '▲' : '●';
  String? _getThreadTrend() => (telemetry.activeThreads > 12) ? '▲' : '●';
  String? _getLatencyTrend() => (telemetry.latencyMs > 100) ? '▲' : '●';
}

class _TelemetryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? trend;
  
  const _TelemetryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.trend,
  });
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color.withValues(alpha: 0.7), size: 14),
          const SizedBox(width: 4),
          Text(label, style: NexusTheme.monoTiny.copyWith(color: color.withValues(alpha: 0.7))),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: NexusTheme.monoTiny.copyWith(color: NexusTheme.pureWhite, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trend != null)
            Text(
              trend!,
              style: NexusTheme.monoTiny.copyWith(
                color: trend == '▲' ? NexusTheme.red : (trend == '▼' ? NexusTheme.emerald : color),
                fontWeight: FontWeight.bold,
              ),
            ).animate().scale(duration: 1000.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }
}
