import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final Widget child;
  const BasePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container()),
        SizedBox(
          width: 1600,
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
