import 'package:flutter/material.dart';

import '../../providers/presentation/providers_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const KeyedSubtree(
    key: Key('provider-settings'),
    child: ProvidersScreen(),
  );
}
