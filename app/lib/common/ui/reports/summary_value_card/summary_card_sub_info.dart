import 'package:flutter/material.dart';

class SummaryCardSubInfo extends StatelessWidget {
  final Widget info;

  const SummaryCardSubInfo({
    super.key,
    required this.info,
  });

  factory SummaryCardSubInfo.text({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    return SummaryCardSubInfo(
      info: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

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
