import 'package:flutter/material.dart';

class AccountabilityTableDateCell extends StatelessWidget {
  final String date;
  final bool isEditing;

  const AccountabilityTableDateCell({
    super.key,
    required this.date,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = Text(date, style: theme.textTheme.labelSmall);

    if (!isEditing) {
      return dateText;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Editando',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(height: 4),
        dateText,
      ],
    );
  }
}
