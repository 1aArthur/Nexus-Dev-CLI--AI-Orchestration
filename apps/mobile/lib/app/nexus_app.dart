import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/nexus_theme.dart';
import 'router.dart';

class NexusApp extends StatefulWidget {
  const NexusApp({super.key});

  @override
  State<NexusApp> createState() => _NexusAppState();
}

class _NexusAppState extends State<NexusApp> {
  late final GoRouter _router = createNexusRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nexus',
      debugShowCheckedModeBanner: false,
      theme: NexusTheme.oled,
      routerConfig: _router,
    );
  }
}
