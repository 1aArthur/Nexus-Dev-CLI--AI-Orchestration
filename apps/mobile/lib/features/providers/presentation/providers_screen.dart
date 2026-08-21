import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/api/generated/contracts.dart';
import '../../../design/tokens.dart';
import '../application/provider_controller.dart';
import '../domain/reasoning_profile.dart';

class ProvidersScreen extends StatelessWidget {
  const ProvidersScreen({this.capabilities = const <ModelCapabilityDto>[], super.key});

  final List<ModelCapabilityDto> capabilities;

  @override
  Widget build(BuildContext context) {
    const endpointPolicy = ProviderEndpointPolicy();
    return ListView(
      key: const Key('provider-control'),
      padding: const EdgeInsets.all(NexusSpacing.x4),
      children: <Widget>[
        Text('AI providers', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: NexusSpacing.x2),
        const Text(
          'Credentials are write-only: sent once over authenticated TLS, never returned, logged, or stored by the mobile client.',
        ),
        const SizedBox(height: NexusSpacing.x4),
        ..._providerCards(),
        const SizedBox(height: NexusSpacing.x6),
        Text(
          'Compatible endpoint boundary',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: NexusSpacing.x2),
        const Text('HTTPS is mandatory. URL credentials and local/private literal hosts are rejected.'),
        const SizedBox(height: NexusSpacing.x1),
        Text(endpointPolicy.gatewayEnforcementNotice),
        const SizedBox(height: NexusSpacing.x6),
        Text(
          'Reasoning by exact model',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: NexusSpacing.x3),
        if (capabilities.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(NexusSpacing.x4),
              child: Text(
                'Connect a provider to discover exact model capabilities. Nexus never guesses reasoning mappings.',
              ),
            ),
          )
        else
          ...capabilities.map(_capabilityCard),
      ],
    );
  }

  List<Widget> _providerCards() => const <Widget>[
    _ProviderCard(label: 'OpenAI', mode: 'Native'),
    SizedBox(height: NexusSpacing.x2),
    _ProviderCard(label: 'Anthropic', mode: 'Native'),
    SizedBox(height: NexusSpacing.x2),
    _ProviderCard(label: 'xAI', mode: 'Native'),
    SizedBox(height: NexusSpacing.x2),
    _ProviderCard(label: 'OpenAI-compatible', mode: 'HTTPS + gateway SSRF policy'),
    SizedBox(height: NexusSpacing.x2),
    _ProviderCard(label: 'Anthropic-compatible', mode: 'HTTPS + gateway SSRF policy'),
  ];

  Widget _capabilityCard(ModelCapabilityDto capability) {
    final choices = const ReasoningResolver().choicesFor(capability);
    return Padding(
      padding: const EdgeInsets.only(bottom: NexusSpacing.x3),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(NexusSpacing.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(capability.exactModelId),
              const SizedBox(height: NexusSpacing.x2),
              Wrap(
                spacing: NexusSpacing.x2,
                runSpacing: NexusSpacing.x2,
                children: choices
                    .map(
                      (choice) => Tooltip(
                        message:
                            choice.disabledReason ??
                            (choice.requiresCostWarning
                                ? 'Higher cost and latency expected.'
                                : 'Supported by exact-model metadata.'),
                        child: ChoiceChip(
                          label: Text(choice.profile.label),
                          selected: choice.profile.isAuto,
                          onSelected: choice.enabled ? (_) {} : null,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: NexusSpacing.x3),
              const Text('Native parameter preview'),
              const SizedBox(height: NexusSpacing.x1),
              SelectableText(
                const JsonEncoder.withIndent('  ').convert(
                  choices
                      .where((choice) => choice.enabled)
                      .map(
                        (choice) => <String, Object?>{
                          choice.profile.label: choice.providerParameters,
                        },
                      )
                      .toList(growable: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({required this.label, required this.mode});

  final String label;
  final String mode;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.lock_outline),
        title: Text(label),
        subtitle: Text('$mode · Credential write-only'),
        trailing: const Text('Disconnected'),
      ),
    );
  }
}
