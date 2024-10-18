import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

class TextBallon extends StatefulWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Function({String? text, Color? color, IconData? icon})? onEdit;
  final VoidCallback? onDelete;
  final EdgeInsets padding;

  const TextBallon({
    super.key,
    required this.text,
    required this.color,
    this.onEdit,
    this.onDelete,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    required this.icon,
  });

  @override
  State<TextBallon> createState() => _TextBallonState();
}

class _TextBallonState extends State<TextBallon> {
  bool isEditing = false;

  Color textColor() {
    return widget.color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    var cont = TextEditingController(text: widget.text);
    return DecoratedBox(
      decoration: BoxDecoration(color: widget.color, borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: widget.padding,
        child: Row(
          children: [
            Expanded(
              child: isEditing
                  ? Row(
                      children: [
                        IconButton(
                          icon: Icon(widget.icon, color: textColor()),
                          onPressed: _pickIcon,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            controller: cont,
                            cursorColor: textColor(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor()),
                            onEditingComplete: () {
                              setState(() {
                                widget.onEdit!.call(text: cont.text);
                                isEditing = false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.colorize),
                          color: textColor(),
                          onPressed: () {
                            Color editColor = widget.color;
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
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
                                title: const Text('Editar Texto'),
                                content: SizedBox(
                                  height: 600,
                                  child: ColorPicker(
                                    pickerColor: widget.color,
                                    onColorChanged: (color) => editColor = color,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(widget.icon, color: textColor()),
                        const SizedBox(width: 10),
                        Text(
                          widget.text,
                          style: TextStyle(color: textColor()),
                        ),
                      ],
                    ),
            ),
            widget.onEdit == null
                ? Container()
                : isEditing
                    ? IconButton(
                        color: textColor(),
                        onPressed: () => setState(() => isEditing = false),
                        icon: const Icon(Icons.edit_off),
                      )
                    : IconButton(
                        color: textColor(),
                        onPressed: () => setState(() => isEditing = true),
                        icon: const Icon(Icons.edit),
                      ),
            widget.onDelete == null
                ? Container()
                : IconButton(
                    color: textColor(),
                    onPressed: () => widget.onDelete!.call(),
                    icon: const Icon(Icons.delete),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickIcon() async {
    IconPickerIcon? newIcon = await showIconPicker(
      context,
      configuration: SinglePickerConfiguration(
        title: const Text("Selecione o ícone"),
        adaptiveDialog: true,
        showTooltips: true,
        showSearchBar: true,
        iconPickerShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        iconPackModes: [IconPack.fontAwesomeIcons, IconPack.material, IconPack.cupertino],
        searchComparator: (String search, IconPickerIcon icon) =>
            search.toLowerCase().contains(icon.name.replaceAll('_', ' ').toLowerCase()) ||
            icon.name.toLowerCase().contains(search.toLowerCase()),
      ),
    );

    if (newIcon != null) {
      widget.onEdit!.call(icon: newIcon.data);
    }
  }
}
