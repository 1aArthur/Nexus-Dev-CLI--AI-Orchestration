import 'package:flutter/material.dart';

import '../tokens.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.label, required this.symbol, super.key});

  final String label;
  final IconData symbol;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: NexusColors.raised,
          border: Border.all(color: NexusColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(symbol, size: 16),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
