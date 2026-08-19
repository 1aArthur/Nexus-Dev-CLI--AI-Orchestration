import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';
import '../../ui/viewmodels/main_viewmodel.dart';
import '../../domain/models/models.dart';

class CicdScreen extends StatelessWidget {
  final MainViewModel viewModel;
  
  const CicdScreen({super.key, required this.viewModel});
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final stages = viewModel.currentPipelineStages.value;
        final nativeSpec = viewModel.latestNativeSpec.value;
        final perfProfile = viewModel.performanceProfile.value;
        
        return CosmicStarfieldBackground(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),
              ),
              
              if (stages.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildPipelineStages(stages).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                ),
              
              SliverToBoxAdapter(
                child: _buildPerformanceProfile(perfProfile).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              ),
              
              if (nativeSpec != null)
                SliverToBoxAdapter(
                  child: _buildNativeModule(nativeSpec).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                ),
              
              SliverToBoxAdapter(
                child: _buildQuickActions().animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
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
          Text('CI/CD PIPELINES', style: NexusTheme.monoTitle),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.rocket_launch, size: 16),
            label: Text('DEPLOY', style: NexusTheme.monoTiny),
            onPressed: () => viewModel.triggerPipeline('Production Deploy', 'PRODUCTION'),
            style: ElevatedButton.styleFrom(
              backgroundColor: NexusTheme.emerald,
              foregroundColor: NexusTheme.oledBlack,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPipelineStages(List<PipelineStageInfo> stages) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PIPELINE STAGES', style: NexusTheme.monoLabel),
          const SizedBox(height: 12),
          ...stages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            return _PipelineStageCard(stage: stage, index: index, isLast: index == stages.length - 1);
          }),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceProfile(PerformanceMetricsProfile profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PERFORMANCE PROFILE', style: NexusTheme.monoLabel),
              TextButton(
                onPressed: viewModel.refreshPerformanceProfile,
                child: Text('REFRESH', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.cyan)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _PerfMetricCard('CPU', '${profile.cpuUtilizationPercent.toStringAsFixed(1)}%', '%', NexusTheme.cyan),
              _PerfMetricCard('Memory', '${profile.memoryUsageMb.toStringAsFixed(1)}', 'MB', NexusTheme.purple),
              _PerfMetricCard('APK Size', '${profile.apkSizeMb.toStringAsFixed(1)}', 'MB', NexusTheme.emerald),
              _PerfMetricCard('DEX Methods', '${(profile.dexMethodCount / 1000).toStringAsFixed(1)}', 'K', NexusTheme.amber),
              _PerfMetricCard('Cold Start', '${profile.coldStartTimeMs}', 'ms', NexusTheme.cyan),
              _PerfMetricCard('Warm Start', '${profile.warmStartTimeMs}', 'ms', NexusTheme.purple),
              _PerfMetricCard('GC Pause', '${profile.gcPauseAverageMs.toStringAsFixed(1)}', 'ms', NexusTheme.emerald),
              _PerfMetricCard('JNI Latency', '${profile.jniBridgeLatencyMicroseconds.toStringAsFixed(2)}', 'μs', NexusTheme.amber),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: NexusTheme.radiusMedium,
              border: Border.all(color: NexusTheme.emerald.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: NexusTheme.emerald.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Icon(Icons.flash_on, color: NexusTheme.emerald, size: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NATIVE SIMD SPEEDUP', style: NexusTheme.monoLabel),
                      Text('${profile.nativeSimdSpeedup.toStringAsFixed(1)}x faster', style: NexusTheme.monoTitle.copyWith(color: NexusTheme.emerald)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (profile.recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('RECOMMENDATIONS', style: NexusTheme.monoLabel),
            const SizedBox(height: 8),
            ...profile.recommendations.map((rec) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: NexusTheme.radiusMedium,
                border: Border.all(color: NexusTheme.white10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: NexusTheme.amber, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(rec, style: NexusTheme.monoSmall)),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildNativeModule(NativeModuleSpec spec) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NATIVE MODULE', style: NexusTheme.monoLabel),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: NexusTheme.radiusMedium,
              border: Border.all(color: NexusTheme.purple.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: NexusTheme.purple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.code, color: NexusTheme.purple, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(spec.moduleName, style: NexusTheme.monoBody.copyWith(fontWeight: FontWeight.w600)),
                          Text('${spec.language} • ${spec.targetArch.join(", ")}', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white50)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: spec.isCompiled ? NexusTheme.emerald.withValues(alpha: 0.2) : NexusTheme.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        spec.isCompiled ? 'COMPILED' : 'SOURCE ONLY',
                        style: NexusTheme.monoTiny.copyWith(
                          color: spec.isCompiled ? NexusTheme.emerald : NexusTheme.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('JNI Methods:', style: NexusTheme.monoLabel),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: spec.jniMethods.map((m) => Chip(
                    label: Text(m, style: NexusTheme.monoTiny),
                    backgroundColor: NexusTheme.purple.withValues(alpha: 0.1),
                    side: BorderSide(color: NexusTheme.purple.withValues(alpha: 0.3)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QUICK ACTIONS', style: NexusTheme.monoLabel),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _ActionCard('Generate Native', 'C++20 SIMD Module', Icons.code, NexusTheme.purple, 
                () => viewModel.generateNativeModule('NdkMathAccelerator', 'computeFast', 'C++20')),
              _ActionCard('Generate Native', 'Rust JNI Module', Icons.code, NexusTheme.amber,
                () => viewModel.generateNativeModule('RustCrypto', 'encrypt', 'Rust')),
              _ActionCard('Build APK', 'Release Build', Icons.build, NexusTheme.emerald, () {}),
              _ActionCard('Deploy', 'Production Deploy', Icons.rocket_launch, NexusTheme.cyan,
                () => viewModel.triggerPipeline('Production Release', 'PRODUCTION')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PipelineStageCard extends StatelessWidget {
  final PipelineStageInfo stage;
  final int index;
  final bool isLast;
  
  const _PipelineStageCard({
    required this.stage,
    required this.index,
    required this.isLast,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: stage.statusColor,
                  border: Border.all(color: NexusTheme.oledBlack, width: 2),
                ),
                child: Center(
                  child: Text(stage.statusIcon, style: TextStyle(
                    color: stage.statusColor == NexusTheme.emerald ? NexusTheme.oledBlack : NexusTheme.pureWhite,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  )),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: NexusTheme.white10,
                    margin: const EdgeInsets.only(left: 9, right: 9),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: NexusTheme.radiusMedium,
                border: Border.all(color: stage.statusColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Stage ${index + 1}', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white40)),
                      const Spacer(),
                      if (stage.durationSeconds > 0)
                        Text('${stage.durationSeconds}s', style: NexusTheme.monoTiny.copyWith(color: stage.statusColor)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(stage.name, style: NexusTheme.monoBody.copyWith(fontWeight: FontWeight.w600)),
                  if (stage.logSummary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(stage.logSummary, style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white50)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  
  const _PerfMetricCard(this.label, this.value, this.unit, this.color);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: NexusTheme.radiusMedium,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: NexusTheme.monoLabel),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: NexusTheme.monoTitle.copyWith(fontSize: 20, color: color, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Text(unit, style: NexusTheme.monoTiny.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  
  const _ActionCard(this.title, this.subtitle, this.icon, this.color, this.onTap);
  
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
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: NexusTheme.monoSmall.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white50)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
