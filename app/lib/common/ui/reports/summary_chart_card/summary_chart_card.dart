import 'package:biluca_financas/common/extensions/color_extensions.dart';
import 'package:flutter/material.dart';

class SummaryChartCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget chart;
  final Widget? topRightInfo;
  final Widget? subInfo;
  final IconData? icon;
  final Color? color;
  final bool smallerTitle;

  const SummaryChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.chart,
    this.topRightInfo,
    this.subInfo,
    this.icon,
    this.color,
    this.smallerTitle = false,
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
          spacing: 20,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        if (widget.icon != null)
                          CircleAvatar(
                            backgroundColor: widget.color,
                            radius: widget.smallerTitle ? 12 : 16,
                            child: Icon(
                              widget.icon,
                              size: widget.smallerTitle
                                  ? Theme.of(context).textTheme.bodySmall?.fontSize
                                  : Theme.of(context).textTheme.headlineMedium?.fontSize,
                              color: widget.color?.adaptByLuminance() ?? Colors.white,
                            ),
                          ),
                        Text(
                          widget.title,
                          style: widget.smallerTitle
                              ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )
                              : Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    widget.subtitle != null
                        ? Text(
                            widget.subtitle!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                        : Container(),
                  ],
                ),
                widget.topRightInfo ?? Container(),
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
            Expanded(child: widget.chart),
          ],
        ),
      ),
    );
  }
}
