import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';
import '../../domain/models/models.dart';

class TerminalEmulator extends StatefulWidget {
  final List<TerminalCommandEntity> history;
  final TerminalShellType activeShell;
  final Function(TerminalShellType) onShellChange;
  final Function(String) onExecuteCommand;
  final VoidCallback onClearTerminal;
  final Function(String) onNarrateOutput;
  
  const TerminalEmulator({
    super.key,
    required this.history,
    required this.activeShell,
    required this.onShellChange,
    required this.onExecuteCommand,
    required this.onClearTerminal,
    required this.onNarrateOutput,
  });
  
  @override
  State<TerminalEmulator> createState() => _TerminalEmulatorState();
}

class _TerminalEmulatorState extends State<TerminalEmulator> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<String> _suggestions = [];
  int _suggestionIndex = -1;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  void didUpdateWidget(covariant TerminalEmulator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.history.length != widget.history.length) {
      _scrollToBottom();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildShellSelector(),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.history.length + 1,
              itemBuilder: (context, index) {
                if (index == widget.history.length) {
                  return _buildInputLine();
                }
                return _buildCommandOutput(widget.history[index]);
              },
            ),
          ),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          _buildSuggestions(),
      ],
    );
  }
  
  Widget _buildShellSelector() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF050505),
        border: Border(bottom: BorderSide(color: NexusTheme.white10)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: widget.activeShell.tagColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: widget.activeShell.tagColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              widget.activeShell.promptBadge,
              style: NexusTheme.monoTiny.copyWith(
                color: widget.activeShell.tagColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.activeShell.description,
            style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white40),
          ),
          const Spacer(),
          PopupMenuButton<TerminalShellType>(
            icon: const Icon(Icons.swap_horiz, color: NexusTheme.white40, size: 18),
            color: const Color(0xFF0A0A0A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: NexusTheme.white10)),
            onSelected: widget.onShellChange,
            itemBuilder: (context) => TerminalShellType.all.map((shell) => PopupMenuItem(
              value: shell,
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: shell.tagColor),
                  ),
                  const SizedBox(width: 8),
                  Text(shell.shellName.toUpperCase(), style: NexusTheme.monoSmall),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.clear_all, color: NexusTheme.white40, size: 18),
            onPressed: widget.onClearTerminal,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommandOutput(TerminalCommandEntity cmd) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${cmd.shellType.promptPrefix} ',
                style: NexusTheme.monoBody.copyWith(color: NexusTheme.cyan),
              ),
              Expanded(
                child: SelectableText(
                  cmd.command,
                  style: NexusTheme.monoBody.copyWith(color: NexusTheme.pureWhite),
                ),
              ),
            ],
          ),
        ),
        
        if (cmd.output.isNotEmpty)
          Container(
            padding: const EdgeInsets.only(left: 40, right: 8, bottom: 8),
            child: SelectableText(
              cmd.output,
              style: NexusTheme.monoBody.copyWith(
                color: cmd.isError ? NexusTheme.red : NexusTheme.white70,
                height: 1.5,
              ),
            ),
          ),
        
        Container(
          padding: const EdgeInsets.only(left: 40, bottom: 8),
          child: Row(
            children: [
              Text(
                '[${cmd.agentTag}] ',
                style: NexusTheme.monoTiny.copyWith(color: NexusTheme.cyan),
              ),
              Text(
                '${cmd.executionTimeMs}ms • ${_formatTime(cmd.timestamp)}',
                style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white30),
              ),
              if (cmd.isError) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: NexusTheme.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('ERROR', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.red, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ),
        
        const Divider(height: 1, color: NexusTheme.white05),
      ],
    );
  }
  
  Widget _buildInputLine() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.activeShell.promptPrefix} ',
            style: NexusTheme.monoBody.copyWith(color: NexusTheme.cyan),
          ),
          Expanded(
            child: RawKeyboardListener(
              focusNode: _focusNode,
              onKey: _handleKeyEvent,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: NexusTheme.monoBody.copyWith(color: NexusTheme.pureWhite),
                cursorColor: NexusTheme.cyan,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Enter command...',
                  hintStyle: NexusTheme.monoBody.copyWith(color: NexusTheme.white20),
                ),
                onChanged: _onInputChanged,
                onSubmitted: _onSubmitted,
                autofocus: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestions() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.only(left: 40, right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NexusTheme.cyan.withValues(alpha: 0.5)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final isSelected = index == _suggestionIndex;
          return InkWell(
            onTap: () => _applySuggestion(_suggestions[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: isSelected ? NexusTheme.white10 : Colors.transparent,
              child: Row(
                children: [
                  Icon(
                    _getSuggestionIcon(_suggestions[index]),
                    color: isSelected ? NexusTheme.cyan : NexusTheme.white50,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(_suggestions[index], style: NexusTheme.monoSmall.copyWith(color: isSelected ? NexusTheme.pureWhite : NexusTheme.white70)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _onInputChanged(String value) {
    final lower = value.toLowerCase();
    final words = value.split(' ');
    final lastWord = words.isNotEmpty ? words.last.toLowerCase() : '';
    
    _suggestions = _generateSuggestions(lower, lastWord);
    _showSuggestions = _suggestions.isNotEmpty && lastWord.isNotEmpty;
    _suggestionIndex = -1;
    setState(() {});
  }
  
  void _onSubmitted(String value) {
    if (value.trim().isEmpty) return;
    
    _showSuggestions = false;
    _suggestions = [];
    _suggestionIndex = -1;
    
    widget.onExecuteCommand(value.trim());
    _controller.clear();
    setState(() {});
  }
  
  void _handleKeyEvent(RawKeyEvent event) {
    if (!_showSuggestions || _suggestions.isEmpty) return;
    
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          _suggestionIndex = (_suggestionIndex + 1) % _suggestions.length;
          setState(() {});
          break;
        case LogicalKeyboardKey.arrowUp:
          _suggestionIndex = (_suggestionIndex - 1 + _suggestions.length) % _suggestions.length;
          setState(() {});
          break;
        case LogicalKeyboardKey.tab:
        case LogicalKeyboardKey.enter:
          if (_suggestionIndex >= 0) {
            _applySuggestion(_suggestions[_suggestionIndex]);
          }
          break;
        case LogicalKeyboardKey.escape:
          _showSuggestions = false;
          setState(() {});
          break;
      }
    }
  }
  
  void _applySuggestion(String suggestion) {
    final text = _controller.text;
    final words = text.split(' ');
    if (words.isNotEmpty) {
      words[words.length - 1] = suggestion;
      _controller.text = words.join(' ') + ' ';
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    }
    _showSuggestions = false;
    _suggestions = [];
    _suggestionIndex = -1;
    setState(() {});
  }
  
  List<String> _generateSuggestions(String input, String lastWord) {
    final suggestions = <String>[];
    
    const builtins = ['help', 'clear', 'ls', 'dir', 'pwd', 'whoami', 'date', 'ps', 'top', 'df', 'free', 'env', 'history'];
    
    const nxCommands = ['autopilot', 'debate', 'scan', 'deploy', 'search', 'voice', 'performance', 'build', 'test', 'lint'];
    
    const shellCommands = ['zsh', 'nushell', 'fish', 'nx shell'];
    
    final allCommands = [...builtins, ...nxCommands.map((c) => 'nx $c'), ...shellCommands];
    
    for (final cmd in allCommands) {
      if (cmd.startsWith(lastWord) && !input.contains(cmd.split(' ').first)) {
        suggestions.add(cmd);
      }
    }
    
    if (lastWord.startsWith('/') || lastWord.startsWith('./')) {
      suggestions.addAll(['/home/', '/data/', '/system/', '/sdcard/', './app/', './lib/', './test/']);
    }
    
    return suggestions.take(10).toList();
  }
  
  IconData _getSuggestionIcon(String suggestion) {
    if (suggestion.startsWith('nx ')) return Icons.rocket_launch;
    if (suggestion == 'zsh' || suggestion == 'fish' || suggestion == 'nushell') return Icons.terminal;
    if (suggestion.startsWith('/') || suggestion.startsWith('./')) return Icons.folder;
    return Icons.bolt;
  }
  
  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
}
