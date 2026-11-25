import 'package:flutter/material.dart';

class IdentificationEditFooter extends StatelessWidget {
  final bool isEditing;
  final bool canDelete;
  final VoidCallback onSave;
  final VoidCallback? onDelete;

  const IdentificationEditFooter({
    super.key,
    required this.isEditing,
    required this.onSave,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          if (isEditing && canDelete)
            IconButton(
              key: const Key('identification-delete'),
              onPressed: onDelete,
              tooltip: 'Excluir categoria',
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
            ),
          const Spacer(),
          TextButton(
            key: const Key('identification-cancel'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            key: const Key('identification-save'),
            onPressed: onSave,
            child: Text(isEditing ? 'Salvar alterações' : 'Criar categoria'),
          ),
        ],
      ),
    );
  }
}
