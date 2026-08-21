import 'package:flutter/foundation.dart';

import '../domain/package_descriptor.dart';

abstract interface class PackageActivationStore {
  Future<void> stage(PackageDescriptor package);

  Future<void> commit(PackageDescriptor package);

  Future<void> rollback(PackageKind kind, PackageDescriptor? previous);
}

final class PackageCatalogController extends ChangeNotifier {
  PackageCatalogController({required this.store});

  final PackageActivationStore store;
  final Map<PackageKind, PackageDescriptor> _active =
      <PackageKind, PackageDescriptor>{};
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  PackageDescriptor? active(PackageKind kind) => _active[kind];

  Future<bool> activate(PackageDescriptor package) async {
    final rejection = PackagePolicy.rejectionReason(package);
    if (rejection != null) {
      _errorMessage = rejection;
      notifyListeners();
      return false;
    }

    final previous = _active[package.kind];
    try {
      await store.stage(package);
      await store.commit(package);
      _active[package.kind] = package;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on Object {
      await store.rollback(package.kind, previous);
      if (previous == null) {
        _active.remove(package.kind);
      } else {
        _active[package.kind] = previous;
      }
      _errorMessage = 'Activation failed; the prior package was restored.';
      notifyListeners();
      return false;
    }
  }
}
