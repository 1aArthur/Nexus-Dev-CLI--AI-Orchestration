import 'package:flutter/foundation.dart';

enum EngineRole {
  productionWeb,
  experimentalWeb,
  specializedRenderer,
  nativeUi,
}

enum EngineAvailability {
  available,
  adapterPending,
  experimentalDisabled,
  notInstalled,
}

enum EngineCapability {
  navigation,
  cookies,
  permissions,
  downloads,
  serviceWorkers,
  webRtc,
  webGl,
  webGpu,
  extensions,
  devTools,
  siteIsolation,
}

enum EngineRejectionCode {
  invalidContext,
  unknownEngine,
  contextAlreadyActive,
  engineUnavailable,
  notArbitraryWebEngine,
  experimentalOptInRequired,
  missingCapabilities,
}

@immutable
final class EngineDescriptor {
  const EngineDescriptor({
    required this.id,
    required this.name,
    required this.role,
    required this.availability,
    required this.supportsArbitraryWeb,
    required this.bundled,
    required this.capabilities,
    required this.summary,
  });

  final String id;
  final String name;
  final EngineRole role;
  final EngineAvailability availability;
  final bool supportsArbitraryWeb;
  final bool bundled;
  final Set<EngineCapability> capabilities;
  final String summary;
}

@immutable
final class EngineSelectionRequest {
  const EngineSelectionRequest({
    required this.contextId,
    required this.engineId,
    this.requiredCapabilities = const <EngineCapability>{},
    this.allowExperimental = false,
  });

  final String contextId;
  final String engineId;
  final Set<EngineCapability> requiredCapabilities;
  final bool allowExperimental;
}

@immutable
final class EngineSelectionDecision {
  const EngineSelectionDecision.accepted(EngineDescriptor engine)
    : allowed = true,
      engine = engine,
      rejectionCode = null,
      missingCapabilities = const <EngineCapability>{};

  const EngineSelectionDecision.rejected({
    required this.rejectionCode,
    this.engine,
    this.missingCapabilities = const <EngineCapability>{},
  }) : allowed = false;

  final bool allowed;
  final EngineDescriptor? engine;
  final EngineRejectionCode? rejectionCode;
  final Set<EngineCapability> missingCapabilities;
}

abstract final class EngineCatalog {
  static const current = <EngineDescriptor>[
    EngineDescriptor(
      id: 'system-webview',
      name: 'System WebView',
      role: EngineRole.productionWeb,
      availability: EngineAvailability.adapterPending,
      supportsArbitraryWeb: true,
      bundled: false,
      capabilities: <EngineCapability>{
        EngineCapability.navigation,
        EngineCapability.cookies,
        EngineCapability.permissions,
        EngineCapability.downloads,
      },
      summary: 'Production path. The typed Flutter adapter is the next gate.',
    ),
    EngineDescriptor(
      id: 'servo',
      name: 'Servo',
      role: EngineRole.experimentalWeb,
      availability: EngineAvailability.notInstalled,
      supportsArbitraryWeb: true,
      bundled: false,
      capabilities: <EngineCapability>{},
      summary:
          'Experimental Rust engine; admission requires measured evidence.',
    ),
    EngineDescriptor(
      id: 'ultralight',
      name: 'Ultralight',
      role: EngineRole.specializedRenderer,
      availability: EngineAvailability.notInstalled,
      supportsArbitraryWeb: false,
      bundled: false,
      capabilities: <EngineCapability>{},
      summary:
          'Specialized native renderer; never the default arbitrary-Web path.',
    ),
    EngineDescriptor(
      id: 'lynx',
      name: 'Lynx',
      role: EngineRole.nativeUi,
      availability: EngineAvailability.notInstalled,
      supportsArbitraryWeb: false,
      bundled: false,
      capabilities: <EngineCapability>{},
      summary: 'Native UI runtime; not a browser engine.',
    ),
  ];
}

extension EngineRoleLabel on EngineRole {
  String get label => switch (this) {
    EngineRole.productionWeb => 'Production Web',
    EngineRole.experimentalWeb => 'Experimental Web',
    EngineRole.specializedRenderer => 'Specialized renderer',
    EngineRole.nativeUi => 'Native UI',
  };
}

extension EngineAvailabilityLabel on EngineAvailability {
  String get label => switch (this) {
    EngineAvailability.available => 'Available',
    EngineAvailability.adapterPending => 'Adapter pending',
    EngineAvailability.experimentalDisabled => 'Experimental disabled',
    EngineAvailability.notInstalled => 'Not installed',
  };
}
