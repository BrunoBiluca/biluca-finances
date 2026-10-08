import 'package:flutter/material.dart';

class SummaryCardSubInfo extends StatelessWidget {
  final Widget info;

  const SummaryCardSubInfo({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        child: info,
      ),
    );
  }
}
