import 'package:flutter/material.dart';

class NexusApp extends StatefulWidget {
  const NexusApp({super.key});

  @override
  State<NexusApp> createState() => _NexusAppState();
}

class _NexusAppState extends State<NexusApp> {
  late final RouterConfig<_NexusRoute> _routerConfig = RouterConfig<_NexusRoute>(
    routerDelegate: _NexusRouterDelegate(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nexus',
      debugShowCheckedModeBanner: false,
      routerConfig: _routerConfig,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          surface: Colors.black,
          onSurface: Colors.white,
        ),
      ),
    );
  }
}

class _NexusRoute {
  const _NexusRoute();
}

class _NexusRouterDelegate extends RouterDelegate<_NexusRoute>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<_NexusRoute> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  _NexusRoute get currentConfiguration => const _NexusRoute();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: <Page<void>>[
        MaterialPage<void>(
          child: Scaffold(
            body: Center(
              child: Semantics(
                header: true,
                child: const Text('NEXUS'),
              ),
            ),
          ),
        ),
      ],
      onDidRemovePage: (page) {},
    );
  }

  @override
  Future<void> setNewRoutePath(_NexusRoute configuration) async {}
}
