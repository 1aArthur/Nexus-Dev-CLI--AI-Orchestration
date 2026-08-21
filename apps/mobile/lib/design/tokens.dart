import 'package:flutter/material.dart';

abstract final class NexusColors {
  static const oled = Color(0xFF000000);
  static const raised = Color(0xFF0D0D0D);
  static const white = Color(0xFFFFFFFF);
  static const muted = Color(0xFFB3B3B3);
  static const border = Color(0xFF5C5C5C);
  static const focus = Color(0xFF737373);

  static const values = <Color>[oled, raised, white, muted, border, focus];
}

abstract final class NexusSpacing {
  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
}

abstract final class NexusBreakpoints {
  static const tablet = 720.0;
  static const contentMax = 1120.0;
}
