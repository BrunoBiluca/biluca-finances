import 'package:biluca_financas/formatter.dart';
import 'package:flutter/material.dart';

class SingleValueCard extends StatelessWidget {
  final String title;
  final double value;
  const SingleValueCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Formatter.value(value),
              key: const Key("valor"),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            SizedBox(height: 30),
            Text(
              title,
              key: const Key("título"),
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
      ),
    );
  }
}
