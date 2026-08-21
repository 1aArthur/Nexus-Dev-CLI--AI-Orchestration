import '../domain/engine_contract.dart';

final class EngineRegistry {
  EngineRegistry(Iterable<EngineDescriptor> engines)
    : _engines = <String, EngineDescriptor>{
        for (final engine in engines) engine.id: engine,
      };

  final Map<String, EngineDescriptor> _engines;
  final Map<String, EngineDescriptor> _activeByContext =
      <String, EngineDescriptor>{};

  EngineSelectionDecision evaluate(EngineSelectionRequest request) {
    if (request.contextId.trim().isEmpty) {
      return const EngineSelectionDecision.rejected(
        rejectionCode: EngineRejectionCode.invalidContext,
      );
    }
    if (_activeByContext.containsKey(request.contextId)) {
      return const EngineSelectionDecision.rejected(
        rejectionCode: EngineRejectionCode.contextAlreadyActive,
      );
    }

    final engine = _engines[request.engineId];
    if (engine == null) {
      return const EngineSelectionDecision.rejected(
        rejectionCode: EngineRejectionCode.unknownEngine,
      );
    }
    if (engine.availability != EngineAvailability.available) {
      return EngineSelectionDecision.rejected(
        rejectionCode: EngineRejectionCode.engineUnavailable,
        engine: engine,
      );
    }
    if (!engine.supportsArbitraryWeb ||
        (engine.role != EngineRole.productionWeb &&
            engine.role != EngineRole.experimentalWeb)) {
      return EngineSelectionDecision.rejected(
        rejectionCode: EngineRejectionCode.notArbitraryWebEngine,
        engine: engine,
      );
    }
    if (engine.role == EngineRole.experimentalWeb &&
        !request.allowExperimental) {
      return EngineSelectionDecision.rejected(
        rejectionCode: EngineRejectionCode.experimentalOptInRequired,
        engine: engine,
      );
    }

    final missing = request.requiredCapabilities.difference(
      engine.capabilities,
    );
    if (missing.isNotEmpty) {
      return EngineSelectionDecision.rejected(
        rejectionCode: EngineRejectionCode.missingCapabilities,
        engine: engine,
        missingCapabilities: Set<EngineCapability>.unmodifiable(missing),
      );
    }
    return EngineSelectionDecision.accepted(engine);
  }

  EngineSelectionDecision activate(EngineSelectionRequest request) {
    final decision = evaluate(request);
    if (decision.allowed) {
      _activeByContext[request.contextId] = decision.engine!;
    }
    return decision;
  }

  EngineDescriptor? activeEngineFor(String contextId) =>
      _activeByContext[contextId];

  void release(String contextId) => _activeByContext.remove(contextId);
}
