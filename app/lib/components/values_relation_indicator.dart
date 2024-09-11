import 'package:flutter/material.dart';

abstract class ValuesRelationIndicator extends StatelessWidget {
  const ValuesRelationIndicator({super.key});

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

  double get rotation => 0;
  Color get bgColor;
  Color get borderColor;
  Color get txtColor;
  IconData get icon;
}
