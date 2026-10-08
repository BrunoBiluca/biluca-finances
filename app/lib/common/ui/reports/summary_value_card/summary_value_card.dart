import 'package:biluca_financas/common/extensions/color_extensions.dart';
import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/common/ui/hover_wrapper.dart';
import 'package:biluca_financas/common/ui/reports/summary_value_card/summary_card_label.dart';
import 'package:biluca_financas/common/ui/reports/summary_value_card/summary_card_sub_info.dart';
import 'package:flutter/material.dart';

class SummaryValueCard extends StatefulWidget {
  final String title;
  final double value;
  final Color color;
  final Widget? subInfo;
  final SummaryCardLabel? label;
  final IconData? icon;
  final Color? iconColor;

  const SummaryValueCard({
    super.key,
    required this.title,
    required this.value,
    this.color = Colors.white,
    this.subInfo,
    this.label,
    this.icon,
    this.iconColor,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  if (widget.icon != null)
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.iconColor?.addBrightness(-100),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(widget.icon, color: widget.iconColor),
                      ),
                    ),
                  Expanded(
                    child: Column(
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
                  ),
                  if (widget.label != null) widget.label!,
                ],
              ),
              if (widget.subInfo != null) Spacer(),
              if (widget.subInfo != null) SummaryCardSubInfo(info: widget.subInfo!),
            ],
          ),
        ),
      ),
    );
  }
}
