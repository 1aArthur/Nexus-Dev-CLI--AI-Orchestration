import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/nexus_theme.dart';

class CosmicNavigationDrawer extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;
  
  const CosmicNavigationDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.85;
    
    return Drawer(
      backgroundColor: NexusTheme.oledBlack,
      width: width,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: NexusTheme.white10)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: NexusTheme.orbGradient,
                      boxShadow: NexusTheme.glowShadow,
                    ),
                    child: const Center(child: Icon(Icons.auto_awesome, color: NexusTheme.oledBlack, size: 20)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NEXUS DEV', style: NexusTheme.monoTitle),
                      Text('ORCHESTRATOR', style: NexusTheme.monoSmall.copyWith(color: NexusTheme.cyan)),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _DrawerSection(
                    title: 'CORE',
                    items: [
                      _DrawerItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, title: 'Dashboard', route: 'dashboard', isSelected: currentRoute == 'dashboard', onTap: () => onNavigate('dashboard')),
                      _DrawerItem(icon: Icons.group_outlined, selectedIcon: Icons.group, title: 'Agent Monitor', route: 'agents', isSelected: currentRoute == 'agents', onTap: () => onNavigate('agents')),
                      _DrawerItem(icon: Icons.terminal_outlined, selectedIcon: Icons.terminal, title: 'Terminal', route: 'terminal', isSelected: currentRoute == 'terminal', onTap: () => onNavigate('terminal')),
                    ],
                  ),
                  _DrawerSection(
                    title: 'DEVOPS',
                    items: [
                      _DrawerItem(icon: Icons.account_tree_outlined, selectedIcon: Icons.account_tree, title: 'Workflows', route: 'workflows', isSelected: currentRoute == 'workflows', onTap: () => onNavigate('workflows')),
                      _DrawerItem(icon: Icons.rocket_launch_outlined, selectedIcon: Icons.rocket_launch, title: 'CI/CD Pipelines', route: 'cicd', isSelected: currentRoute == 'cicd', onTap: () => onNavigate('cicd')),
                      _DrawerItem(icon: Icons.security_outlined, selectedIcon: Icons.security, title: 'Security Center', route: 'security', isSelected: currentRoute == 'security', onTap: () => onNavigate('security')),
                    ],
                  ),
                  _DrawerSection(
                    title: 'INTELLIGENCE',
                    items: [
                      _DrawerItem(icon: Icons.search_outlined, selectedIcon: Icons.search, title: 'Exa Search', route: 'exa_search', isSelected: currentRoute == 'exa_search', onTap: () => onNavigate('exa_search')),
                      _DrawerItem(icon: Icons.psychology_outlined, selectedIcon: Icons.psychology, title: 'Agent Orchestrator', route: 'orchestrator', isSelected: currentRoute == 'orchestrator', onTap: () => onNavigate('orchestrator')),
                    ],
                  ),
                  _DrawerSection(
                    title: 'TOOLS',
                    items: [
                      _DrawerItem(icon: Icons.build_outlined, selectedIcon: Icons.build, title: 'Tools Hub', route: 'tools_hub', isSelected: currentRoute == 'tools_hub', onTap: () => onNavigate('tools_hub')),
                      _DrawerItem(icon: Icons.extension_outlined, selectedIcon: Icons.extension, title: 'MCP Tools', route: 'mcp_tools', isSelected: currentRoute == 'mcp_tools', onTap: () => onNavigate('mcp_tools')),
                      _DrawerItem(icon: Icons.code_outlined, selectedIcon: Icons.code, title: 'Skills', route: 'skills', isSelected: currentRoute == 'skills', onTap: () => onNavigate('skills')),
                    ],
                  ),
                  _DrawerSection(
                    title: 'SYSTEM',
                    items: [
                      _DrawerItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings, title: 'Settings', route: 'settings', isSelected: currentRoute == 'settings', onTap: () => onNavigate('settings')),
                    ],
                  ),
                ],
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: NexusTheme.white10)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: NexusTheme.emerald,
                          boxShadow: [BoxShadow(color: NexusTheme.emerald.withValues(alpha: 0.5), blurRadius: 8)],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('SYSTEM OPERATIONAL', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.emerald)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('v1.0.0 • Build 2024.08.19', style: NexusTheme.monoTiny.copyWith(color: NexusTheme.white30)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final List<_DrawerItem> items;
  
  const _DrawerSection({required this.title, required this.items});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: NexusTheme.monoLabel),
        ),
        ...items,
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final String route;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.route,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? NexusTheme.white10 : Colors.transparent,
        borderRadius: NexusTheme.radiusMedium,
        border: Border.all(
          color: isSelected ? NexusTheme.cyan.withValues(alpha: 0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? NexusTheme.cyan : NexusTheme.white60,
          size: 20,
        ),
        title: Text(
          title,
          style: NexusTheme.monoSmall.copyWith(
            color: isSelected ? NexusTheme.pureWhite : NexusTheme.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
      ),
    );
  }
}
