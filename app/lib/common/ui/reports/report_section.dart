import 'package:flutter/material.dart';

class ReportSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const ReportSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Row(
          spacing: 10,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.secondary),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}
