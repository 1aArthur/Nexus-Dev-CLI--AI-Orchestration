import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/nexus_theme.dart';
import 'ui/viewmodels/main_viewmodel.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/terminal_screen.dart';
import 'ui/screens/agent_monitor_screen.dart';
import 'ui/screens/security_center_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/exa_search_screen.dart';
import 'ui/screens/workflows_screen.dart';
import 'ui/screens/cicd_screen.dart';
import 'ui/components/cosmic_orb_nav_button.dart';
import 'ui/components/cosmic_navigation_drawer.dart';
import 'data/local/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  runApp(
    ProviderScope(
      overrides: [
        hiveInitProvider.overrideWith(() => Hive.initFlutter()),
      ],
      child: const NexusDevOrchestratorApp(),
    ),
  );
}

class NexusDevOrchestratorApp extends ConsumerWidget {
  const NexusDevOrchestratorApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(hiveInitProvider);
    
    return MaterialApp(
      title: 'Nexus Dev Orchestrator',
      theme: NexusTheme.themeData,
      darkTheme: NexusTheme.themeData,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const MainShell(),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});
  
  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> with TickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _showAutopilotSheet = false;
  String _currentRoute = 'dashboard';
  
  final List<_BottomTab> _tabs = [
    _BottomTab('dashboard', 'Dashboard', Icons.dashboard_outlined, Icons.dashboard),
    _BottomTab('agents', 'Agents', Icons.group, Icons.group_outlined),
    _BottomTab('terminal', 'Terminal', Icons.terminal, Icons.terminal_outlined),
    _BottomTab('settings', 'Settings', Icons.settings, Icons.settings_outlined),
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentRoute = _tabs[_tabController.index].route;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _navigateTo(String route) {
    final index = _tabs.indexWhere((t) => t.route == route);
    if (index != -1) {
      _tabController.animateTo(index);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(mainViewModelProvider);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: NexusTheme.oledBlack,
      drawer: CosmicNavigationDrawer(
        currentRoute: _currentRoute,
        onNavigate: (route) {
          _navigateTo(route);
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              DashboardScreen(
                viewModel: viewModel,
                onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                onNavigateToWorkflows: () => _navigateTo('workflows'),
                onNavigateToAgents: () => _navigateTo('agents'),
                onNavigateToSecurity: () => _navigateTo('security'),
                onNavigateToTerminal: () => _navigateTo('terminal'),
              ),
              AgentMonitorScreen(viewModel: viewModel),
              TerminalScreen(viewModel: viewModel),
              SettingsScreen(viewModel: viewModel),
            ],
          ),
          
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Center(
              child: CosmicOrbNavButton(
                onTap: () => setState(() => _showAutopilotSheet = true),
              ),
            ),
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(),
          ),
          
          if (_showAutopilotSheet)
            _buildAutopilotSheet(viewModel),
        ],
      ),
    );
  }
  
  Widget _buildBottomNav() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: NexusTheme.oledBlack,
        border: Border(top: BorderSide(color: NexusTheme.white10, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ..._tabs.take(2).map((tab) => _buildNavItem(tab)),
            const SizedBox(width: 56),
            ..._tabs.skip(2).map((tab) => _buildNavItem(tab)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavItem(_BottomTab tab) {
    final isSelected = _currentRoute == tab.route;
    return Expanded(
      child: InkWell(
        onTap: () => _navigateTo(tab.route),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? tab.selectedIcon : tab.unselectedIcon,
              color: isSelected ? NexusTheme.pureWhite : NexusTheme.white40,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              tab.title,
              style: NexusTheme.monoTiny.copyWith(
                color: isSelected ? NexusTheme.pureWhite : NexusTheme.white40,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAutopilotSheet(MainViewModel viewModel) {
    return Container(
      color: NexusTheme.black70,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: NexusTheme.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('AUTOPILOT ACTIONS', style: NexusTheme.monoLabel),
            const SizedBox(height: 16),
            _AutopilotAction(
              icon: Icons.auto_awesome,
              title: 'Full Autopilot',
              subtitle: 'Complete production delivery pipeline',
              onTap: () {
                viewModel.startOrchestration('Autopilot Swarm Completo');
                _navigateTo('agents');
                setState(() => _showAutopilotSheet = false);
              },
            ),
            _AutopilotAction(
              icon: Icons.security,
              title: 'Security Scan',
              subtitle: 'MASVS static analysis + SCA',
              onTap: () {
                viewModel.runMasvsStaticAnalysis('CoreAuthService.dart', viewModel.currentAuditedCode.value);
                _navigateTo('security');
                setState(() => _showAutopilotSheet = false);
              },
            ),
            _AutopilotAction(
              icon: Icons.search,
              title: 'Exa Research',
              subtitle: 'Deep web technical intelligence',
              onTap: () {
                _navigateTo('exa_search');
                setState(() => _showAutopilotSheet = false);
              },
            ),
            _AutopilotAction(
              icon: Icons.terminal,
              title: 'Terminal Exec',
              subtitle: 'Execute CLI commands',
              onTap: () {
                _navigateTo('terminal');
                setState(() => _showAutopilotSheet = false);
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _showAutopilotSheet = false),
              child: Text('DISMISS', style: NexusTheme.monoSmall.copyWith(color: NexusTheme.cyan)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _BottomTab {
  final String route;
  final String title;
  final IconData selectedIcon;
  final IconData unselectedIcon;
  
  _BottomTab(this.route, this.title, this.selectedIcon, this.unselectedIcon);
}

class _AutopilotAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  
  const _AutopilotAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: NexusTheme.white10,
          borderRadius: NexusTheme.radiusMedium,
          border: Border.all(color: NexusTheme.white10),
        ),
        child: Icon(icon, color: NexusTheme.cyan, size: 20),
      ),
      title: Text(title, style: NexusTheme.monoBody),
      subtitle: Text(subtitle, style: NexusTheme.monoSmall),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
