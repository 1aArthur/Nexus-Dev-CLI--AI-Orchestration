import 'package:flutter/material.dart';

/// High-contrast Nexus brand mark for OLED surfaces.
class NexusBrandMark extends StatelessWidget {
  const NexusBrandMark({
    this.size = 40,
    super.key,
  });

  static const assetName = 'assets/branding/nexus_hex_bolt_oled.png';
  static const semanticLabel = 'Nexus: hexagono, equalizador e raio';

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        assetName,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel: semanticLabel,
      ),
    );
  }
}
