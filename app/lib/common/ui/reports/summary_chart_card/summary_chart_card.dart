import 'package:flutter/material.dart';

class SummaryChartCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget chart;
  final Widget? legend;
  final Widget? subInfo;

  const SummaryChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.chart,
    this.legend,
    this.subInfo,
  });

  @override
  State<SummaryChartCard> createState() => _SummaryChartCardState();
}

class _SummaryChartCardState extends State<SummaryChartCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          spacing: 30,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                widget.legend ?? Container(),
              ],
            ),
            widget.subInfo != null
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                      child: widget.subInfo,
                    ),
                  )
                : Container(),
            SizedBox(
              height: 400,
              width: double.infinity,
              child: widget.chart,
            ),
          ],
        ),
      ),
    );
  }
}
