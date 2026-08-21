import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mobile/core/api/generated/contracts.dart';
import 'package:nexus_mobile/features/providers/application/provider_controller.dart';

void main() {
  // Catches accidental credential retention, echoing, retries, or non-TLS
  // submission when saving a compatible provider.
  test('credential is written once and never retained or returned', () async {
    final writer = _FakeCredentialWriter();
    final controller = ProviderController(credentialWriter: writer);
    const secret = 'task9-private-sentinel';

    await controller.saveCredential(
      provider: ProviderKind.openaiCompatible,
      credential: secret,
      endpoint: Uri.parse('https://gateway.example.com/v1'),
    );

    expect(writer.submissions, hasLength(1));
    expect(writer.submissions.single.credential, secret);
    expect(controller.state.connected, true);
    expect(controller.state.toString(), isNot(contains(secret)));
    expect(controller.toString(), isNot(contains(secret)));
    expect(writer.submissions.single.toString(), isNot(contains(secret)));
  });

  test('rejected compatible endpoint never transmits a credential', () async {
    final writer = _FakeCredentialWriter();
    final controller = ProviderController(credentialWriter: writer);

    await expectLater(
      controller.saveCredential(
        provider: ProviderKind.anthropicCompatible,
        credential: 'another-private-sentinel',
        endpoint: Uri.parse('http://127.0.0.1:8080'),
      ),
      throwsFormatException,
    );

    expect(writer.submissions, isEmpty);
  });
}

final class _FakeCredentialWriter implements ProviderCredentialWriter {
  final submissions = <ProviderCredentialSubmission>[];

  @override
  Future<ProviderCredentialReceipt> writeCredential(
    ProviderCredentialSubmission submission,
  ) async {
    submissions.add(submission);
    return ProviderCredentialReceipt(
      provider: submission.provider,
      credentialId: 'credential-server-reference',
      connectedAt: DateTime.utc(2026, 8, 21),
    );
  }
}
