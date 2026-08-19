import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';
import '../../ui/viewmodels/main_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  final MainViewModel viewModel;
  
  const SettingsScreen({super.key, required this.viewModel});
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return CosmicStarfieldBackground(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),
              
              _buildApiKeysSection().animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              
              _buildVoiceSection().animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              
              _buildTerminalSection().animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              
              _buildAppearanceSection().animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              
              _buildAboutSection().animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        Text('SETTINGS', style: NexusTheme.monoTitle),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: NexusTheme.emerald.withValues(alpha: 0.2),
            borderRadius: NexusTheme.radiusMedium,
            border: Border.all(color: NexusTheme.emerald),
          ),
          child: Text('v1.0.0', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.emerald, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
  
  Widget _buildApiKeysSection() {
    return _SettingsSection(
      title: 'API KEYS',
      icon: Icons.key,
      children: [
        _ApiKeyField(
          label: 'Gemini API Key',
          hint: 'Enter your Gemini API key',
          value: viewModel.customGeminiKey.value,
          onChanged: viewModel.setCustomGeminiKey,
          isSecure: true,
        ),
        _ApiKeyField(
          label: 'Exa Search API Key',
          hint: 'Enter your Exa API key',
          value: viewModel.customExaKey.value,
          onChanged: viewModel.setCustomExaKey,
          isSecure: true,
        ),
        _ApiKeyField(
          label: 'Grok Voice API Key',
          hint: 'Enter your Grok (X.AI) API key',
          value: viewModel.customGrokKey.value,
          onChanged: viewModel.setCustomGrokKey,
          isSecure: true,
        ),
      ],
    );
  }
  
  Widget _buildVoiceSection() {
    return _SettingsSection(
      title: 'VOICE SYNTHESIS',
      icon: Icons.mic,
      children: [
        _SettingsTile(
          title: 'Grok WebSocket Voice',
          subtitle: 'Real-time voice-to-text with Grok',
          trailing: ElevatedButton(
            onPressed: () => viewModel.connectGrokVoice(),
            style: ElevatedButton.styleFrom(
              backgroundColor: NexusTheme.cyan,
              foregroundColor: NexusTheme.oledBlack,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text('CONNECT', style: NexusTheme.monoTiny),
          ),
        ),
        _SettingsTile(
          title: 'TTS Voice',
          subtitle: 'Text-to-speech synthesis',
          trailing: DropdownButton<String>(
            value: 'Grok-CyberVoice',
            dropdownColor: const Color(0xFF0A0A0A),
            style: NexusTheme.monoSmall,
            underline: const SizedBox(),
            items: ['Grok-CyberVoice', 'System Default', 'Neural Female', 'Neural Male']
                .map((v) => DropdownMenuItem(value: v, child: Text(v, style: NexusTheme.monoSmall)))
                .toList(),
            onChanged: (v) {},
          ),
        ),
        _SettingsTile(
          title: 'Speech Rate',
          subtitle: 'Adjust speaking speed',
          trailing: SizedBox(
            width: 120,
            child: Slider(
              value: 1.0,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              activeColor: NexusTheme.cyan,
              onChanged: (v) => viewModel.setSpeechRate(v),
            ),
          ),
        ),
        _SettingsTile(
          title: 'Pitch',
          subtitle: 'Adjust voice pitch',
          trailing: SizedBox(
            width: 120,
            child: Slider(
              value: 1.05,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              activeColor: NexusTheme.purple,
              onChanged: (v) => viewModel.setPitch(v),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTerminalSection() {
    return _SettingsSection(
      title: 'TERMINAL',
      icon: Icons.terminal,
      children: [
        _SettingsTile(
          title: 'Default Shell',
          subtitle: 'Choose your preferred shell',
          trailing: DropdownButton<TerminalShellType>(
            value: viewModel.activeShell.value,
            dropdownColor: const Color(0xFF0A0A0A),
            style: NexusTheme.monoSmall,
            underline: const SizedBox(),
            items: TerminalShellType.all.map((s) => DropdownMenuItem(
              value: s,
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: s.tagColor)),
                  const SizedBox(width: 8),
                  Text(s.shellName.toUpperCase(), style: NexusTheme.monoSmall),
                ],
              ),
            )).toList(),
            onChanged: (v) => v != null ? viewModel.setActiveShell(v) : null,
          ),
        ),
        _SettingsTile(
          title: 'Font Size',
          subtitle: 'Terminal font size',
          trailing: SizedBox(
            width: 120,
            child: Slider(
              value: 14.0,
              min: 10.0,
              max: 20.0,
              divisions: 10,
              activeColor: NexusTheme.emerald,
              onChanged: (v) {},
            ),
          ),
        ),
        _SettingsTile(
          title: 'Cursor Blink',
          subtitle: 'Blinking cursor animation',
          trailing: Switch(
            value: true,
            activeColor: NexusTheme.cyan,
            onChanged: (v) {},
          ),
        ),
      ],
    );
  }
  
  Widget _buildAppearanceSection() {
    return _SettingsSection(
      title: 'APPEARANCE',
      icon: Icons.palette,
      children: [
        _SettingsTile(
          title: 'Theme',
          subtitle: 'OLED True Black (Fixed)',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: NexusTheme.oledBlack,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NexusTheme.pureWhite),
            ),
            child: Text('OLED BLACK', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.pureWhite, fontWeight: FontWeight.w600)),
          ),
        ),
        _SettingsTile(
          title: 'Accent Color',
          subtitle: 'Minimal accent usage',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ColorDot(NexusTheme.cyan, true),
              _ColorDot(NexusTheme.purple, false),
              _ColorDot(NexusTheme.emerald, false),
              _ColorDot(NexusTheme.amber, false),
            ],
          ),
        ),
        _SettingsTile(
          title: 'Animations',
          subtitle: 'Enable UI animations',
          trailing: Switch(
            value: true,
            activeColor: NexusTheme.cyan,
            onChanged: (v) {},
          ),
        ),
      ],
    );
  }
  
  Widget _buildAboutSection() {
    return _SettingsSection(
      title: 'ABOUT',
      icon: Icons.info_outline,
      children: [
        _SettingsTile(
          title: 'Nexus Dev Orchestrator',
          subtitle: 'Full-Stack DevSecOps CLI v1.0.0',
        ),
        _SettingsTile(
          title: 'Build Date',
          subtitle: '2024-08-19',
        ),
        _SettingsTile(
          title: 'Flutter Version',
          subtitle: '3.19+',
        ),
        _SettingsTile(
          title: 'License',
          subtitle: 'MIT License',
          onTap: () {},
        ),
        _SettingsTile(
          title: 'Source Code',
          subtitle: 'GitHub Repository',
          onTap: () {},
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: NexusTheme.radiusLarge,
        border: Border.all(color: NexusTheme.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: NexusTheme.cyan, size: 20),
                const SizedBox(width: 8),
                Text(title, style: NexusTheme.monoLabel),
              ],
            ),
          ),
          Divider(height: 1, color: NexusTheme.white10),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: NexusTheme.monoSmall),
                  Text(subtitle, style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white40)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _ApiKeyField extends StatelessWidget {
  final String label;
  final String hint;
  final String value;
  final Function(String) onChanged;
  final bool isSecure;
  
  const _ApiKeyField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    required this.isSecure,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: NexusTheme.monoSmall),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: value),
            obscureText: isSecure,
            style: NexusTheme.monoSmall,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: NexusTheme.monoSmall.copyWith(color: NexusTheme.white30),
              filled: true,
              fillColor: const Color(0xFF050505),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  
  const _ColorDot(this.color, this.selected);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: selected ? Border.all(color: NexusTheme.pureWhite, width: 2) : null,
      ),
    );
  }
}
