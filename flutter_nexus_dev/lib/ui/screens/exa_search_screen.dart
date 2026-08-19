import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';
import '../../ui/viewmodels/main_viewmodel.dart';
import '../../domain/models/models.dart';

class ExaSearchScreen extends StatelessWidget {
  final MainViewModel viewModel;
  
  const ExaSearchScreen({super.key, required this.viewModel});
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return CosmicStarfieldBackground(
          child: Column(
            children: [
              _buildSearchBar().animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),
              
              Expanded(
                child: _buildResults().animate().fadeIn(delay: 200.ms),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSearchBar() {
    final controller = TextEditingController();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('EXA NEURAL SEARCH', style: NexusTheme.monoTitle),
              const Spacer(),
              if (viewModel.isSearchingExa.value)
                SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(NexusTheme.cyan)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: NexusTheme.monoBody,
                  decoration: InputDecoration(
                    hintText: 'Search the web... (e.g., "Flutter SIMD optimization")',
                    hintStyle: NexusTheme.monoSmall.copyWith(color: NexusTheme.white30),
                    prefixIcon: Icon(Icons.search, color: NexusTheme.white40),
                    filled: true,
                    fillColor: const Color(0xFF0A0A0A),
                    border: OutlineInputBorder(
                      borderRadius: NexusTheme.radiusMedium,
                      borderSide: BorderSide(color: NexusTheme.white10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: NexusTheme.radiusMedium,
                      borderSide: BorderSide(color: NexusTheme.white10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: NexusTheme.radiusMedium,
                      borderSide: BorderSide(color: NexusTheme.cyan, width: 2),
                    ),
                  ),
                  onSubmitted: (value) => viewModel.searchExa(value),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.bolt, size: 18),
                label: Text('SEARCH', style: NexusTheme.monoTiny),
                onPressed: () => viewModel.searchExa(controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusTheme.cyan,
                  foregroundColor: NexusTheme.oledBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildResults() {
    final results = viewModel.exaResults.value;
    
    if (results.isEmpty && !viewModel.isSearchingExa.value) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _SearchResultCard(result: result, index: index);
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: NexusTheme.white20),
          const SizedBox(height: 16),
          Text('NO RESULTS', style: NexusTheme.monoTitle.copyWith(color: NexusTheme.white40)),
          const SizedBox(height: 8),
          Text('Enter a query to search the web with Exa', style: NexusTheme.monoSmall.copyWith(color: NexusTheme.white30)),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final ExaResult result;
  final int index;
  
  const _SearchResultCard({required this.result, required this.index});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: NexusTheme.radiusMedium,
        border: Border.all(color: NexusTheme.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: NexusTheme.cyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(child: Text('${index + 1}', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.cyan, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(result.title, style: NexusTheme.monoSmall.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              Text('${(result.score * 100).toInt()}%', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.cyan, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(result.text, style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white60), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              if (result.author.isNotEmpty) ...[
                Icon(Icons.person, size: 12, color: NexusTheme.white30),
                const SizedBox(width: 4),
                Text(result.author, style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white40)),
                const SizedBox(width: 16),
              ],
              if (result.publishedDate.isNotEmpty) ...[
                Icon(Icons.calendar_today, size: 12, color: NexusTheme.white30),
                const SizedBox(width: 4),
                Text(result.publishedDate, style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white40)),
                const SizedBox(width: 16),
              ],
              const Spacer(),
              IconButton(
                icon: Icon(Icons.open_in_new, size: 16, color: NexusTheme.cyan),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                icon: Icon(Icons.content_copy, size: 16, color: NexusTheme.white40),
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
}
