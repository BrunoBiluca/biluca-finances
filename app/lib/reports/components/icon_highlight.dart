import 'package:flutter/material.dart';

class IconHighlight extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final Color txtColor;
  final IconData icon;
  final double rotation;

  const IconHighlight({
    super.key,
    required this.bgColor,
    required this.borderColor,
    required this.txtColor,
    required this.icon,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: borderColor, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Transform.rotate(
          angle: rotation,
          child: Icon(
            icon,
            color: txtColor,
            size: Theme.of(context).textTheme.displayLarge?.fontSize,
          ),
        ),
      ),
    );
  }
}
