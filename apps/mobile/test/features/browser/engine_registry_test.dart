import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/features/browser/application/engine_registry.dart';
import 'package:nexus_mobile/features/browser/domain/engine_contract.dart';

void main() {
  // Catches a production catalog that falsely marks an unbound or experimental
  // runtime as ready, which could silently increase the package or weaken the
  // production engine boundary.
  test('default catalog keeps alternative runtimes out of production', () {
    final catalog = EngineCatalog.current;

    expect(catalog.map((engine) => engine.name), <String>[
      'System WebView',
      'Servo',
      'Ultralight',
      'Lynx',
    ]);
    expect(catalog.where((engine) => engine.bundled), isEmpty);
    expect(catalog.first.role, EngineRole.productionWeb);
    expect(catalog.first.availability, EngineAvailability.adapterPending);
    expect(catalog[1].role, EngineRole.experimentalWeb);
    expect(catalog[2].role, EngineRole.specializedRenderer);
    expect(catalog[3].role, EngineRole.nativeUi);
  });

  // Catches a registry that changes an active browsing context after a
  // rejected request or permits two engines to own one context concurrently.
  test('one accepted Web engine owns a context until release', () {
    final registry = EngineRegistry(<EngineDescriptor>[
      _systemWebView,
      _experimentalServo,
    ]);

    final first = registry.activate(
      const EngineSelectionRequest(
        contextId: 'tab-1',
        engineId: 'system-webview',
        requiredCapabilities: <EngineCapability>{
          EngineCapability.navigation,
          EngineCapability.cookies,
        },
      ),
    );
    final second = registry.activate(
      const EngineSelectionRequest(
        contextId: 'tab-1',
        engineId: 'servo',
        allowExperimental: true,
      ),
    );

    expect(first.allowed, true);
    expect(second.allowed, false);
    expect(second.rejectionCode, EngineRejectionCode.contextAlreadyActive);
    expect(registry.activeEngineFor('tab-1')?.id, 'system-webview');

    registry.release('tab-1');
    expect(registry.activeEngineFor('tab-1'), isNull);
  });

  // Catches fail-open selection when an engine is unknown, unavailable,
  // experimental without opt-in, specialized, or missing a required feature.
  test('selection fails closed with stable reason codes', () {
    final registry = EngineRegistry(<EngineDescriptor>[
      _systemWebView,
      _experimentalServo,
      _ultralight,
      _pendingWebView,
    ]);

    expect(
      registry
          .evaluate(
            const EngineSelectionRequest(
              contextId: 'unknown',
              engineId: 'missing',
            ),
          )
          .rejectionCode,
      EngineRejectionCode.unknownEngine,
    );
    expect(
      registry
          .evaluate(
            const EngineSelectionRequest(
              contextId: 'pending',
              engineId: 'pending-webview',
            ),
          )
          .rejectionCode,
      EngineRejectionCode.engineUnavailable,
    );
    expect(
      registry
          .evaluate(
            const EngineSelectionRequest(
              contextId: 'experimental',
              engineId: 'servo',
            ),
          )
          .rejectionCode,
      EngineRejectionCode.experimentalOptInRequired,
    );
    expect(
      registry
          .evaluate(
            const EngineSelectionRequest(
              contextId: 'specialized',
              engineId: 'ultralight',
            ),
          )
          .rejectionCode,
      EngineRejectionCode.notArbitraryWebEngine,
    );
    expect(
      registry
          .evaluate(
            const EngineSelectionRequest(
              contextId: 'capability',
              engineId: 'system-webview',
              requiredCapabilities: <EngineCapability>{EngineCapability.webGpu},
            ),
          )
          .rejectionCode,
      EngineRejectionCode.missingCapabilities,
    );
  });
}

const _systemWebView = EngineDescriptor(
  id: 'system-webview',
  name: 'System WebView',
  role: EngineRole.productionWeb,
  availability: EngineAvailability.available,
  supportsArbitraryWeb: true,
  bundled: false,
  capabilities: <EngineCapability>{
    EngineCapability.navigation,
    EngineCapability.cookies,
    EngineCapability.permissions,
    EngineCapability.downloads,
  },
  summary: 'Test production adapter.',
);

const _experimentalServo = EngineDescriptor(
  id: 'servo',
  name: 'Servo',
  role: EngineRole.experimentalWeb,
  availability: EngineAvailability.available,
  supportsArbitraryWeb: true,
  bundled: false,
  capabilities: <EngineCapability>{EngineCapability.navigation},
  summary: 'Test experimental adapter.',
);

const _ultralight = EngineDescriptor(
  id: 'ultralight',
  name: 'Ultralight',
  role: EngineRole.specializedRenderer,
  availability: EngineAvailability.available,
  supportsArbitraryWeb: false,
  bundled: false,
  capabilities: <EngineCapability>{EngineCapability.navigation},
  summary: 'Test specialized adapter.',
);

const _pendingWebView = EngineDescriptor(
  id: 'pending-webview',
  name: 'Pending WebView',
  role: EngineRole.productionWeb,
  availability: EngineAvailability.adapterPending,
  supportsArbitraryWeb: true,
  bundled: false,
  capabilities: <EngineCapability>{EngineCapability.navigation},
  summary: 'Test pending adapter.',
);
