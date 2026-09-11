import 'package:flutter/material.dart';

class ReportTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final double verticalOffset;

  const ReportTooltip({
    super.key,
    required this.child,
    required this.message,
    this.verticalOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      preferBelow: false,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: BoxConstraints.loose(Size(160, 100)),
      verticalOffset: verticalOffset,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline,
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: FontWeight.bold,
          ),
      message: message,
      child: child,
    );
  }
}
