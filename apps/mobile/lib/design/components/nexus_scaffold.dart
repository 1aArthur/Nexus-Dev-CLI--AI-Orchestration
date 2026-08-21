import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../tokens.dart';

class NexusDestination {
  const NexusDestination({
    required this.label,
    required this.path,
    required this.icon,
    this.description = '',
  });

  final String label;
  final String path;
  final IconData icon;
  final String description;
}

const primaryDestinations = <NexusDestination>[
  NexusDestination(
    label: 'Dashboard',
    path: '/',
    icon: Icons.dashboard_outlined,
  ),
  NexusDestination(label: 'Agents', path: '/agents', icon: Icons.hub_outlined),
  NexusDestination(
    label: 'Voice',
    path: '/voice',
    icon: Icons.mic_none_outlined,
  ),
  NexusDestination(
    label: 'Terminal',
    path: '/terminal',
    icon: Icons.terminal_outlined,
  ),
  NexusDestination(label: 'More', path: '/more', icon: Icons.apps_outlined),
];

const extendedDestinations = <NexusDestination>[
  NexusDestination(
    label: 'Workflows',
    path: 'workflows',
    icon: Icons.account_tree_outlined,
  ),
  NexusDestination(
    label: 'Research',
    path: 'research',
    icon: Icons.travel_explore_outlined,
  ),
  NexusDestination(
    label: 'Security',
    path: 'security',
    icon: Icons.shield_outlined,
  ),
  NexusDestination(label: 'Tools', path: 'tools', icon: Icons.build_outlined),
  NexusDestination(
    label: 'Skills',
    path: 'skills',
    icon: Icons.auto_awesome_outlined,
  ),
  NexusDestination(
    label: 'CI/CD',
    path: 'cicd',
    icon: Icons.rocket_launch_outlined,
  ),
  NexusDestination(
    label: 'Extensions',
    path: 'extensions',
    icon: Icons.extension_outlined,
  ),
  NexusDestination(
    label: 'Knowledge',
    path: 'knowledge',
    icon: Icons.menu_book_outlined,
  ),
  NexusDestination(
    label: 'Instructions',
    path: 'instructions',
    icon: Icons.rule_outlined,
  ),
  NexusDestination(label: 'Pets', path: 'pets', icon: Icons.pets_outlined),
  NexusDestination(
    label: 'Themes',
    path: 'themes',
    icon: Icons.palette_outlined,
  ),
  NexusDestination(
    label: 'Credits',
    path: 'credits',
    icon: Icons.receipt_long_outlined,
  ),
  NexusDestination(
    label: 'Settings',
    path: 'settings',
    icon: Icons.settings_outlined,
  ),
];

class NexusScaffold extends StatelessWidget {
  const NexusScaffold({
    required this.navigationShell,
    required this.title,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final String title;

  void _selectDestination(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= NexusBreakpoints.tablet;
        final content = Column(
          children: <Widget>[
            _CommandHeader(title: title),
            Expanded(child: navigationShell),
          ],
        );

        if (useRail) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: <Widget>[
                  NavigationRail(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: _selectDestination,
                    labelType: NavigationRailLabelType.all,
                    leading: const Padding(
                      padding: EdgeInsets.only(top: NexusSpacing.x4),
                      child: Icon(Icons.graphic_eq, semanticLabel: 'Nexus'),
                    ),
                    destinations: primaryDestinations
                        .map(
                          (destination) => NavigationRailDestination(
                            icon: Icon(destination.icon),
                            label: Text(destination.label),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: content),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(child: content),
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _selectDestination,
            destinations: primaryDestinations
                .map(
                  (destination) => NavigationDestination(
                    icon: Icon(destination.icon),
                    label: destination.label,
                  ),
                )
                .toList(growable: false),
          ),
        );
      },
    );
  }
}

class _CommandHeader extends StatelessWidget {
  const _CommandHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: NexusSpacing.x4),
      decoration: const BoxDecoration(
        color: NexusColors.oled,
        border: Border(bottom: BorderSide(color: NexusColors.border)),
      ),
      child: Row(
        children: <Widget>[
          const Text(
            'NEXUS',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2),
          ),
          const SizedBox(width: NexusSpacing.x4),
          const SizedBox(height: 24, child: VerticalDivider()),
          const SizedBox(width: NexusSpacing.x4),
          Expanded(
            child: Text(
              title,
              key: const Key('screen-title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
