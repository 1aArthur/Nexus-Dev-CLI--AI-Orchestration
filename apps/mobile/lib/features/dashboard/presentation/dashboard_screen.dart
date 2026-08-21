import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/components/status_badge.dart';
import '../../../design/tokens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: NexusBreakpoints.contentMax),
        child: ListView(
          padding: const EdgeInsets.all(NexusSpacing.x4),
          children: <Widget>[
            Text('Command deck', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: NexusSpacing.x2),
            Text(
              'Coordinate agents and choose exactly where every command runs.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: NexusSpacing.x6),
            Wrap(
              spacing: NexusSpacing.x3,
              runSpacing: NexusSpacing.x3,
              children: <Widget>[
                const Tooltip(
                  message: 'Connect a provider before creating a mission.',
                  child: FilledButton(onPressed: null, child: Text('Create mission')),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/terminal'),
                  icon: const Icon(Icons.terminal_outlined),
                  label: const Text('Choose terminal'),
                ),
              ],
            ),
            const SizedBox(height: NexusSpacing.x6),
            const Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                label: 'No active mission',
                symbol: Icons.pause_circle_outline,
              ),
            ),
            const SizedBox(height: NexusSpacing.x6),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(NexusSpacing.x6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Active work', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: NexusSpacing.x2),
                    const Text(
                      'No mission is running. Connect a provider and select an execution target to begin.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
