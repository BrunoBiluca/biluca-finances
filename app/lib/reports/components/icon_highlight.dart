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
        color: Theme.of(context).colorScheme.outline,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
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
        ),
      ),
    );
  }
}
