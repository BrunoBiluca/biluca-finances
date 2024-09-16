import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color adaptByLuminance() {
    return computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}