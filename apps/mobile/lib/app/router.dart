import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/components/nexus_scaffold.dart';
import '../features/agents/presentation/agent_matrix_screen.dart';
import '../features/browser/presentation/engine_lab_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/execution/presentation/terminal_screen.dart';
import '../features/extensions/domain/package_descriptor.dart';
import '../features/extensions/presentation/extensions_screen.dart';
import '../features/instructions/presentation/instructions_screen.dart';
import '../features/knowledge/presentation/knowledge_screen.dart';
import '../features/missions/presentation/mission_composer_screen.dart';
import '../features/pets/presentation/pets_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/themes/presentation/theme_editor_screen.dart';
import '../features/usage/presentation/credits_screen.dart';
import '../features/voice/presentation/voice_screen.dart';

GoRouter createNexusRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => NexusScaffold(
          navigationShell: navigationShell,
          title: _titleForLocation(state.uri.path),
        ),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/agents',
                builder: (context, state) => AgentMatrixScreen(
                  onCreateMission: () => context.go('/agents/compose'),
                ),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'compose',
                    builder: (context, state) => const MissionComposerScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/voice',
                builder: (context, state) => const VoiceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/terminal',
                builder: (context, state) => const TerminalScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
                routes: extendedDestinations
                    .map(
                      (destination) => GoRoute(
                        path: destination.path,
                        builder: (context, state) =>
                            _screenForDestination(destination),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Widget _screenForDestination(NexusDestination destination) {
  return switch (destination.path) {
    'skills' => const ExtensionsScreen(kindFilter: PackageKind.skill),
    'extensions' => const ExtensionsScreen(),
    'knowledge' => const KnowledgeScreen(),
    'instructions' => const InstructionsScreen(),
    'pets' => const PetsScreen(),
    'themes' => const ThemeEditorScreen(),
    'credits' => CreditsScreen(),
    'settings' => const SettingsScreen(),
    'engine-lab' => const EngineLabScreen(),
    _ => FeaturePlaceholderScreen(
      title: destination.label,
      icon: destination.icon,
    ),
  };
}

String _titleForLocation(String path) {
  if (path == '/') return 'Dashboard';
  for (final destination in primaryDestinations.skip(1)) {
    if (path == destination.path) return destination.label;
  }
  final segment = path.split('/').where((value) => value.isNotEmpty).lastOrNull;
  for (final destination in extendedDestinations) {
    if (segment == destination.path) return destination.label;
  }
  return 'Nexus';
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: extendedDestinations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final destination = extendedDestinations[index];
        return Card(
          child: ListTile(
            minTileHeight: 56,
            leading: Icon(destination.icon),
            title: Text(destination.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/more/${destination.path}'),
          ),
        );
      },
    );
  }
}

class FeaturePlaceholderScreen extends StatelessWidget {
  const FeaturePlaceholderScreen({
    required this.title,
    required this.icon,
    super.key,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Module ready for a configured provider or execution target.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
