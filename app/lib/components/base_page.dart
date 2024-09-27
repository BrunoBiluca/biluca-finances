import 'package:biluca_financas/main_drawner.dart';
import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final Widget child;
  const BasePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 250,
          child: MainDrawner(),
        ),
        Expanded(child: Container()),
        SizedBox(
          width: 1800,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: child,
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }
}
