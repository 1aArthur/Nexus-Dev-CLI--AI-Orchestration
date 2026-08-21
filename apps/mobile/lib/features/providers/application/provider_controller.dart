import '../../../core/api/generated/contracts.dart';

final class EndpointValidation {
  const EndpointValidation._({required this.allowed, required this.reason});

  const EndpointValidation.allowed()
    : this._(allowed: true, reason: 'HTTPS endpoint accepted for gateway review.');

  const EndpointValidation.rejected(String reason)
    : this._(allowed: false, reason: reason);

  final bool allowed;
  final String reason;
}

final class ProviderEndpointPolicy {
  const ProviderEndpointPolicy();

  String get gatewayEnforcementNotice =>
      'The gateway resolves DNS, blocks private/link-local addresses, and '
      'enforces the project domain allowlist before connecting.';

  EndpointValidation validate(Uri endpoint) {
    if (endpoint.scheme != 'https') {
      return const EndpointValidation.rejected('HTTPS is required.');
    }
    if (endpoint.host.isEmpty) {
      return const EndpointValidation.rejected('A public host is required.');
    }
    if (endpoint.userInfo.isNotEmpty) {
      return const EndpointValidation.rejected(
        'Credentials in endpoint URLs are forbidden.',
      );
    }
    if (endpoint.fragment.isNotEmpty) {
      return const EndpointValidation.rejected('URL fragments are forbidden.');
    }

    final host = endpoint.host.toLowerCase();
    if (_isBlockedLiteralHost(host)) {
      return const EndpointValidation.rejected(
        'Loopback, local, and private literal hosts are forbidden.',
      );
    }
    return const EndpointValidation.allowed();
  }

  bool _isBlockedLiteralHost(String host) {
    if (host == 'localhost' || host.endsWith('.localhost')) return true;
    if (host.endsWith('.local') || host.endsWith('.internal')) return true;
    if (host == '::1' ||
        host.startsWith('fc') ||
        host.startsWith('fd') ||
        host.startsWith('fe80:')) {
      return true;
    }

    final octets = host.split('.').map(int.tryParse).toList(growable: false);
    if (octets.length != 4 || octets.any((octet) => octet == null)) {
      return false;
    }
    final first = octets[0]!;
    final second = octets[1]!;
    return first == 0 ||
        first == 10 ||
        first == 127 ||
        (first == 169 && second == 254) ||
        (first == 172 && second >= 16 && second <= 31) ||
        (first == 192 && second == 168) ||
        first >= 224;
  }
}

final class ProviderCredentialSubmission {
  const ProviderCredentialSubmission({
    required this.provider,
    required this.credential,
    this.endpoint,
  });

  final ProviderKind provider;
  final String credential;
  final Uri? endpoint;

  @override
  String toString() =>
      'ProviderCredentialSubmission(provider: ${provider.name}, '
      'endpoint: ${endpoint ?? 'native'}, credential: [REDACTED])';
}

final class ProviderCredentialReceipt {
  const ProviderCredentialReceipt({
    required this.provider,
    required this.credentialId,
    required this.connectedAt,
  });

  final ProviderKind provider;
  final String credentialId;
  final DateTime connectedAt;
}

abstract interface class ProviderCredentialWriter {
  Future<ProviderCredentialReceipt> writeCredential(
    ProviderCredentialSubmission submission,
  );
}

final class ProviderConnectionState {
  const ProviderConnectionState({
    required this.saving,
    required this.connected,
    this.receipt,
    this.error,
  });

  const ProviderConnectionState.disconnected()
    : this(saving: false, connected: false);

  final bool saving;
  final bool connected;
  final ProviderCredentialReceipt? receipt;
  final String? error;

  @override
  String toString() =>
      'ProviderConnectionState(saving: $saving, connected: $connected, '
      'credentialId: ${receipt?.credentialId ?? 'none'}, error: $error)';
}

final class ProviderController {
  ProviderController({
    required ProviderCredentialWriter credentialWriter,
    this.endpointPolicy = const ProviderEndpointPolicy(),
  }) : _credentialWriter = credentialWriter;

  final ProviderCredentialWriter _credentialWriter;
  final ProviderEndpointPolicy endpointPolicy;
  ProviderConnectionState state = const ProviderConnectionState.disconnected();

  Future<void> saveCredential({
    required ProviderKind provider,
    required String credential,
    Uri? endpoint,
  }) async {
    if (state.saving) throw StateError('A credential write is already active.');
    if (credential.trim().isEmpty || credential.length > 8192) {
      throw const FormatException('Credential must contain 1–8192 characters.');
    }
    if (_isCompatible(provider) && endpoint == null) {
      throw const FormatException('Compatible providers require an endpoint.');
    }
    if (endpoint != null) {
      final validation = endpointPolicy.validate(endpoint);
      if (!validation.allowed) throw FormatException(validation.reason);
    }

    state = const ProviderConnectionState(saving: true, connected: false);
    try {
      final receipt = await _credentialWriter.writeCredential(
        ProviderCredentialSubmission(
          provider: provider,
          credential: credential,
          endpoint: endpoint,
        ),
      );
      state = ProviderConnectionState(
        saving: false,
        connected: true,
        receipt: receipt,
      );
    } on Object catch (error) {
      state = ProviderConnectionState(
        saving: false,
        connected: false,
        error: error.runtimeType.toString(),
      );
      rethrow;
    }
  }

  bool _isCompatible(ProviderKind provider) =>
      provider == ProviderKind.openaiCompatible ||
      provider == ProviderKind.anthropicCompatible;

  @override
  String toString() => 'ProviderController(state: $state)';
}
