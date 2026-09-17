import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color adaptByLuminance() {
    return computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Color addBrightness(double amount) => Color.fromARGB(
        (a * 255.0).round().clamp(0, 255),
        ((r * 255).round() + amount.round()).clamp(0, 255),
        ((g * 255).round() + amount.round()).clamp(0, 255),
        ((b * 255).round() + amount.round()).clamp(0, 255),
      );
}
