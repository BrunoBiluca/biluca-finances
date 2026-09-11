import 'package:flutter/material.dart';

class CenteredIcon extends StatelessWidget {
  const CenteredIcon({
    super.key,
    required this.icon,
    this.color,
    this.size,
  });

  final IconData icon;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Text(
      String.fromCharCode(icon.codePoint),
      style: TextStyle(
        inherit: false,
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color,
      ),
    );
  }
}