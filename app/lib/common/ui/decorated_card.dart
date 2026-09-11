import 'package:flutter/material.dart';

class DecoratedCard extends StatelessWidget {
  final Widget child;
  const DecoratedCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 4),
      ),
      child: Padding(padding: const EdgeInsets.all(32.0), child: child),
    );
  }
}
