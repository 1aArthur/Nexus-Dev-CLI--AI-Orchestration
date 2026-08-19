import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';
import '../../domain/models/models.dart';

class CodeViewer extends StatefulWidget {
  final String code;
  final List<SecurityFinding> findings;
  final Function(String) onCodeChanged;
  
  const CodeViewer({
    super.key,
    required this.code,
    required this.findings,
    required this.onCodeChanged,
  });
  
  @override
  State<CodeViewer> createState() => _CodeViewerState();
}

class _CodeViewerState extends State<CodeViewer> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.code);
  }
  
  @override
  void didUpdateWidget(covariant CodeViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code) {
      _controller.text = widget.code;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final lines = _controller.text.split('\n');
    final findingLines = <int, List<SecurityFinding>>{};
    
    for (final finding in widget.findings) {
      if (finding.line > 0 && finding.line <= lines.length) {
        findingLines.putIfAbsent(finding.line, () => []).add(finding);
      }
    }
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF030406),
        borderRadius: NexusTheme.radiusMedium,
        border: Border.all(color: NexusTheme.white10),
      ),
      child: Column(
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF050505),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: NexusTheme.white10)),
            ),
            child: Row(
              children: [
                _ToolbarButton(icon: Icons.copy, tooltip: 'Copy', onTap: _copyCode),
                _ToolbarButton(icon: Icons.download, tooltip: 'Download', onTap: _downloadCode),
                const Spacer(),
                Text('${lines.length} lines', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white40)),
              ],
            ),
          ),
          Expanded(
            child: RawKeyboardListener(
              focusNode: _focusNode,
              onKey: (event) {
                if (event is RawKeyDownEvent && event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyS) {
                  widget.onCodeChanged(_controller.text);
                }
              },
              child: ListView(
                controller: ScrollController(),
                padding: EdgeInsets.zero,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          color: const Color(0xFF050505),
                          child: Column(
                            children: List.generate(lines.length, (i) {
                              final lineNum = i + 1;
                              final hasFinding = findingLines.containsKey(lineNum);
                              return Container(
                                height: 22,
                                alignment: Alignment.topRight,
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  '$lineNum',
                                  style: NexusTheme.monoTiny.copyWith(
                                    color: hasFinding ? findingLines[lineNum]!.first.severity.color : NexusTheme.white30,
                                    fontWeight: hasFinding ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 600),
                          padding: const EdgeInsets.only(top: 12, bottom: 12, right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(lines.length, (i) {
                              final lineNum = i + 1;
                              final line = lines[i];
                              final hasFinding = findingLines.containsKey(lineNum);
                              final finding = hasFinding ? findingLines[lineNum]!.first : null;
                              
                              return Container(
                                height: 22,
                                color: hasFinding ? finding!.severity.color.withValues(alpha: 0.08) : Colors.transparent,
                                padding: const EdgeInsets.only(left: 12),
                                child: SelectableText(
                                  line,
                                  style: NexusTheme.monoTiny.copyWith(
                                    color: _getLineColor(line, finding),
                                    height: 1.4,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _copyCode() {}
  void _downloadCode() {}
  
  Color _getLineColor(String line, SecurityFinding? finding) {
    if (finding != null) return finding.severity.color;
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('//') || trimmed.startsWith('/*')) return NexusTheme.white40;
    if (trimmed.startsWith('import') || trimmed.startsWith('package')) return NexusTheme.purple;
    if (RegExp(r'^\s*(class|interface|enum|abstract|final|const|var|val|fun|function)\b').hasMatch(trimmed)) return NexusTheme.cyan;
    if (RegExp(r'^\s*(if|else|for|while|switch|case|return|try|catch|finally|throw)\b').hasMatch(trimmed)) return NexusTheme.amber;
    if (RegExp(r'["\'].*["\']').hasMatch(line)) return NexusTheme.emerald;
    return NexusTheme.white;
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  
  const _ToolbarButton({required this.icon, required this.tooltip, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(icon, color: NexusTheme.white50, size: 16),
        ),
      ),
    );
  }
}
