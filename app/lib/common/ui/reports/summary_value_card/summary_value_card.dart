import 'package:biluca_financas/common/extensions/color_extensions.dart';
import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/common/ui/hover_wrapper.dart';
import 'package:biluca_financas/common/ui/reports/summary_value_card/summary_card_label.dart';
import 'package:flutter/material.dart';

class SummaryValueCard extends StatefulWidget {
  final String title;
  final double value;
  final Color color;
  final Widget? subInfo;
  final SummaryCardLabel? label;

  const SummaryValueCard({
    super.key,
    required this.title,
    required this.value,
    this.color = Colors.white,
    this.subInfo,
    this.label,
  });

  @override
  State<SummaryValueCard> createState() => _SummaryValueCardState();
}

class _SummaryValueCardState extends State<SummaryValueCard> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return HoverWrapper(
      onHover: (value) => setState(() => isHover = value),
      child: Card(
        color: isHover ? Theme.of(context).cardColor.addBrightness(10) : Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title.toUpperCase(),
                        key: const Key("título"),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        Formatter.value(widget.value),
                        key: const Key("valor"),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(color: widget.color),
                      ),
                    ],
                  ),
                  widget.label ?? Container(),
                ],
              ),
              Spacer(),
              widget.subInfo ?? Container(),
            ],
          ),
        ),
      ),
    );
  }
}
