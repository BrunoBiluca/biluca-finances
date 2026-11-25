import 'package:biluca_financas/app/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SummaryCardLabel extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;
  final Color bgColor;

  const SummaryCardLabel({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    required this.bgColor,
  });

  SummaryCardLabel.positive({
    super.key,
    required this.label,
    required AppColors colors,
    this.icon,
  })  : color = colors.positiveYield,
        bgColor = colors.positiveYieldBg;

  SummaryCardLabel.positiveAlt({
    super.key,
    required this.label,
    required AppColors colors,
    this.icon,
  })  : color = colors.positiveYieldAlt,
        bgColor = colors.positiveYieldAltBg;

  SummaryCardLabel.negative({
    super.key,
    required this.label,
    required AppColors colors,
    this.icon,
  })  : color = colors.negativeYield,
        bgColor = colors.negativeYieldBg;

  SummaryCardLabel.neutral({
    super.key,
    required this.label,
    required AppColors colors,
    this.icon,
  })  : color = colors.neutralYield,
        bgColor = colors.neutralYieldBg;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
        child: Row(
          spacing: 8,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: color,
                size: Theme.of(context).textTheme.bodySmall!.fontSize,
              ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
