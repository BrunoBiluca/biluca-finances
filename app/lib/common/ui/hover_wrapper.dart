import 'package:flutter/material.dart';

class HoverWrapper extends StatelessWidget {
  final Function(bool) onHover;
  final Widget child;
  const HoverWrapper({
    super.key,
    required this.onHover,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => onHover(true),
      onExit: (event) => onHover(false),
      child: child,
    );
  }
}
