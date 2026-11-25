import 'package:biluca_financas/app/themes/app_colors.dart';
import 'package:flutter/material.dart';

class ReportHeader extends StatelessWidget {
  static const double narrowBreakpoint = 850;

  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> actions;
  final Widget? periodSelector;

  const ReportHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.actions = const [],
    this.periodSelector,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final titleRow = Row(
          spacing: 10,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
                color: context.appColors.sidebarHighlightBackground,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon, color: iconColor),
              ),
            ),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );

        if (constraints.maxWidth < narrowBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              titleRow,
              if (actions.isNotEmpty)
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: actions,
                ),
              if (periodSelector != null) periodSelector!,
            ],
          );
        }

        return Row(
          spacing: 20,
          children: [
            Expanded(flex: 2, child: titleRow),
            ...actions,
            if (periodSelector != null) Flexible(child: periodSelector!),
          ],
        );
      },
    );
  }
}
