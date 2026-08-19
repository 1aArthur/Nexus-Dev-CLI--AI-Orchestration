import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';
import '../../ui/viewmodels/main_viewmodel.dart';
import '../../domain/models/models.dart';
import '../components/masvs_vulnerability_card.dart';
import '../components/code_viewer.dart';

class SecurityCenterScreen extends StatelessWidget {
  final MainViewModel viewModel;
  
  const SecurityCenterScreen({super.key, required this.viewModel});
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final scanResult = viewModel.masvsScanResult.value;
        
        return CosmicStarfieldBackground(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),
              ),
              
              if (scanResult != null)
                SliverToBoxAdapter(
                  child: _buildMasvsSummary(scanResult).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                ),
              
              SliverToBoxAdapter(
                child: _buildCodeEditor(scanResult).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              ),
              
              if (scanResult != null && scanResult.findings.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildVulnerabilityList(scanResult).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
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
          Text('SECURITY CENTER', style: NexusTheme.monoTitle),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.security, size: 16),
            label: Text('RUN SCAN', style: NexusTheme.monoTiny),
            onPressed: () => viewModel.runMasvsStaticAnalysis('CoreAuthService.dart', viewModel.currentAuditedCode.value),
            style: ElevatedButton.styleFrom(
              backgroundColor: NexusTheme.cyan,
              foregroundColor: NexusTheme.oledBlack,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.auto_fix_high, size: 16),
            label: Text('AUTO-FIX ALL', style: NexusTheme.monoTiny),
            onPressed: viewModel.applyAllMasvsPatches,
            style: OutlinedButton.styleFrom(
              foregroundColor: NexusTheme.emerald,
              side: BorderSide(color: NexusTheme.emerald),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMasvsSummary(MasvsScanResult result) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: NexusTheme.radiusLarge,
              border: Border.all(color: _getGradeColor(result.complianceGrade).withValues(alpha: 0.5), width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MASVS v2.0 COMPLIANCE', style: NexusTheme.monoLabel),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${result.complianceScore}',
                            style: NexusTheme.monoLarge.copyWith(
                              fontSize: 48,
                              color: _getGradeColor(result.complianceGrade),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/ 100',
                            style: NexusTheme.monoTitle.copyWith(color: NexusTheme.white50),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getGradeColor(result.complianceGrade),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'GRADE ${result.complianceGrade}',
                              style: NexusTheme.monoTiny.copyWith(color: NexusTheme.oledBlack, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('${result.linesScanned} lines scanned in ${result.scanDurationMs}ms', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white40)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _SeverityStat('CRITICAL', result.criticalCount, NexusTheme.red),
                    _SeverityStat('HIGH', result.highCount, NexusTheme.amber),
                    _SeverityStat('MEDIUM', result.mediumCount, NexusTheme.amber),
                    _SeverityStat('LOW', result.lowCount, NexusTheme.cyan),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: result.categories.length,
            itemBuilder: (context, index) {
              final cat = result.categories[index];
              return _CategoryCard(category: cat);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildCodeEditor(MasvsScanResult? result) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('SOURCE CODE', style: NexusTheme.monoLabel),
              const Spacer(),
              Text('CoreAuthService.dart', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white40)),
            ],
          ),
          const SizedBox(height: 8),
          CodeViewer(
            code: viewModel.currentAuditedCode.value,
            findings: result?.findings ?? [],
            onCodeChanged: (newCode) => viewModel.currentAuditedCode.value = newCode,
          ),
        ],
      ),
    );
  }
  
  Widget _buildVulnerabilityList(MasvsScanResult result) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('VULNERABILITIES (${result.totalVulnerabilities})', style: NexusTheme.monoLabel),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: result.findings.length,
            itemBuilder: (context, index) {
              return MasvsVulnerabilityCard(
                finding: result.findings[index],
                onApplyPatch: viewModel.applyMasvsPatch,
              );
            },
          ),
        ],
      ),
    );
  }
  
  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return NexusTheme.emerald;
      case 'B':
        return NexusTheme.cyan;
      case 'C':
        return NexusTheme.amber;
      case 'D':
        return NexusTheme.red;
      default:
        return NexusTheme.red;
    }
  }
}

class _SeverityStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  
  const _SeverityStat(this.label, this.count, this.color);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 8),
          Text(label, style: NexusTheme.monoTiny.copyWith(color: color)),
          const SizedBox(width: 8),
          Text(count.toString(), style: NexusTheme.monoSmall.copyWith(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final MasvsCategoryMetric category;
  
  const _CategoryCard({required this.category});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: NexusTheme.radiusMedium,
        border: Border.all(color: category.isCompliant ? NexusTheme.emerald.withValues(alpha: 0.3) : category.maxSeverity.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: category.isCompliant ? NexusTheme.emerald : category.maxSeverity.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(category.categoryName, style: NexusTheme.monoSmall.copyWith(fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${category.findingsCount} findings', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white50)),
              Text(category.maxSeverity.label, style: NexusTheme.monoTiny.copyWith(color: category.maxSeverity.color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: category.isCompliant ? 1.0 : 0.3,
            backgroundColor: NexusTheme.white10,
            valueColor: AlwaysStoppedAnimation<Color>(category.isCompliant ? NexusTheme.emerald : category.maxSeverity.color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}
