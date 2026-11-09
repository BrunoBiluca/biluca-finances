import 'package:biluca_financas/common/extensions/color_extensions.dart';
import 'package:biluca_financas/common/ui/base_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

class TextBallonEditOption {
  final IconData icon;
  final String name;
  final VoidCallback onTap;

  TextBallonEditOption({
    required this.icon,
    required this.name,
    required this.onTap,
  });
}

class TextBallon extends StatefulWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Function({String? text, Color? color, IconData? icon})? onEdit;
  final VoidCallback? onDelete;
  final List<TextBallonEditOption>? editOptions;
  final EdgeInsets padding;
  final bool tintedStyle;

  const TextBallon({
    super.key,
    required this.text,
    required this.color,
    this.onEdit,
    this.onDelete,
    this.editOptions,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    this.tintedStyle = false,
    required this.icon,
  });

  @override
  State<TextBallon> createState() => _TextBallonState();
}

class _TextBallonState extends State<TextBallon> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    var cont = TextEditingController(text: widget.text);
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.tintedStyle
            ? widget.color.withValues(alpha: 0.16)
            : widget.color,
        border: widget.tintedStyle
            ? Border.all(color: widget.color.withValues(alpha: 0.5))
            : null,
        borderRadius: BorderRadius.all(
          Radius.circular(widget.tintedStyle ? 999 : 10),
        ),
      ),
      child: Padding(
        padding: widget.padding,
        child: Row(
          children: [
            Expanded(
              child: isEditing
                  ? renderEditMode(cont, context)
                  : renderBaseMode(context),
            ),
            widget.onEdit == null
                ? Container()
                : IconButton(
                    color: _actionColor(theme),
                    onPressed: () => setState(() => isEditing = !isEditing),
                    icon: isEditing ? Icon(Icons.edit_off) : Icon(Icons.edit),
                  ),
            widget.onDelete == null
                ? Container()
                : IconButton(
                    color: _actionColor(theme),
                    onPressed: () => widget.onDelete!.call(),
                    icon: const Icon(Icons.delete),
                  ),
          ],
        ),
      ),
    );
  }

  Color _actionColor(ThemeData theme) {
    return widget.tintedStyle
        ? theme.colorScheme.onSurfaceVariant
        : widget.color.adaptByLuminance();
  }

  Row renderBaseMode(BuildContext context) {
    return Row(
      children: [
        Icon(
          widget.icon,
          color: widget.tintedStyle
              ? widget.color
              : widget.color.adaptByLuminance(),
        ),
        const SizedBox(width: 10),
        Text(
          widget.text,
          style: TextStyle(
            color: widget.tintedStyle
                ? widget.color
                : widget.color.adaptByLuminance(),
          ),
        ),
      ],
    );
  }

  Row renderEditMode(TextEditingController cont, BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = widget.tintedStyle
        ? theme.colorScheme.onSurface
        : widget.color.adaptByLuminance();
    return Row(
      spacing: 20,
      children: [
        IconButton(
          icon: Icon(widget.icon, color: foregroundColor),
          onPressed: () => _pickIcon(widget.text),
        ),
        Expanded(
          child: TextField(
            autofocus: true,
            controller: cont,
            cursorColor: foregroundColor,
            style: theme.textTheme.bodySmall?.copyWith(color: foregroundColor),
            onEditingComplete: () {
              setState(() {
                widget.onEdit!.call(text: cont.text);
                isEditing = false;
              });
            },
          ),
        ),
        ...(widget.editOptions ?? []).map(
          (option) => IconButton(
            icon: Icon(option.icon),
            color: _actionColor(theme),
            onPressed: option.onTap,
          ),
        ),
        IconButton(
            icon: const Icon(Icons.colorize),
            color: _actionColor(theme),
            onPressed: () => showColorEditDialog(context, widget.color)),
      ],
    );
  }

  Future<dynamic> showColorEditDialog(BuildContext context, Color editColor) {
    return showDialog(
      context: context,
      builder: (context) => BaseDialog(
        actions: [
          SizedBox(
            width: 200,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
          ),
          SizedBox(
            width: 200,
            child: TextButton(
              onPressed: () {
                setState(() {
                  widget.onEdit!.call(color: editColor);
                  isEditing = false;
                });
                Navigator.pop(context);
              },
              child: const Text("Salvar"),
            ),
          ),
        ],
        title: 'Editar Texto',
        content: SizedBox(
          height: 600,
          child: ColorPicker(
            pickerColor: widget.color,
            onColorChanged: (color) => editColor = color,
          ),
        ),
      ),
    );
  }

  Future<void> _pickIcon(String description) async {
    IconPickerIcon? newIcon = await showIconPicker(
      context,
      configuration: SinglePickerConfiguration(
        title: Text("Selecione o ícone para '$description'"),
        adaptiveDialog: true,
        showTooltips: true,
        searchHintText: "Procure pelo ícone",
        showSearchBar: true,
        noResultsText: "Sem resultados para:",
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        iconSize: 24,
        iconPickerShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        iconPackModes: [
          IconPack.fontAwesomeIcons,
          IconPack.material,
          IconPack.cupertino
        ],
        searchComparator: (String search, IconPickerIcon icon) =>
            search
                .toLowerCase()
                .contains(icon.name.replaceAll('_', ' ').toLowerCase()) ||
            icon.name.toLowerCase().contains(search.toLowerCase()),
      ),
    );

    if (newIcon != null) {
      widget.onEdit!.call(icon: newIcon.data);
    }
  }
}
