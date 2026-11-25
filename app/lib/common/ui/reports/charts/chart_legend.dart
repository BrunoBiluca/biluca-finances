import 'package:flutter/material.dart';

class ChartLegendItem {
  final String label;
  final Color color;

  const ChartLegendItem({required this.label, required this.color});
}

class ChartLegend extends StatelessWidget {
  final List<ChartLegendItem> items;

  const ChartLegend({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 8,
      children: items
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                CircleAvatar(backgroundColor: item.color, radius: 10),
                Text(item.label),
              ],
            ),
          )
          .toList(),
    );
  }
}
