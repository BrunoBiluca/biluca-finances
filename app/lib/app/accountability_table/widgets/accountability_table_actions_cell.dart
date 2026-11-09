import 'package:flutter/material.dart';

class AccountabilityTableActionsCell {
  final int rowIndex;
  final bool enableInlineEditing;
  final bool isEditing;
  final IconData removeIcon;
  final String removeTooltip;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onRemove;

  const AccountabilityTableActionsCell({
    required this.rowIndex,
    required this.enableInlineEditing,
    required this.isEditing,
    required this.removeIcon,
    required this.removeTooltip,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
    required this.onRemove,
  });

  DataCell build(BuildContext context) {
    if (!enableInlineEditing) {
      return DataCell(
        Semantics(
          button: true,
          label: removeTooltip,
          child: IconButton(
            key: Key('remove-accountability-$rowIndex'),
            onPressed: onRemove,
            icon: Icon(
              removeIcon,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    return DataCell(
      isEditing
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  button: true,
                  label: 'Salvar edição',
                  child: IconButton(
                    key: Key('save-accountability-edit-$rowIndex'),
                    onPressed: onSave,
                    icon: const Icon(Icons.check),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Cancelar edição',
                  child: IconButton(
                    key: Key('cancel-accountability-edit-$rowIndex'),
                    onPressed: onCancel,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  button: true,
                  label: 'Editar lançamento',
                  child: IconButton(
                    key: Key('edit-accountability-$rowIndex'),
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ),
                Semantics(
                  button: true,
                  label: removeTooltip,
                  child: IconButton(
                    key: Key('remove-accountability-$rowIndex'),
                    onPressed: onRemove,
                    icon: Icon(
                      removeIcon,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
