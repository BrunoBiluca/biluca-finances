import 'package:biluca_financas/common/extensions/color_extensions.dart';
import 'package:biluca_financas/components/base_dialog.dart';
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
                          icon: Icon(widget.icon, color: widget.color.adaptByLuminance()),
                          onPressed: () => _pickIcon(widget.text),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            controller: cont,
                            cursorColor: widget.color.adaptByLuminance(),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(color: widget.color.adaptByLuminance()),
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
                          color: widget.color.adaptByLuminance(),
                          onPressed: () {
                            Color editColor = widget.color;
                            showDialog(
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
                          },
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(widget.icon, color: widget.color.adaptByLuminance()),
                        const SizedBox(width: 10),
                        Text(
                          widget.text,
                          style: TextStyle(color: widget.color.adaptByLuminance()),
                        ),
                      ],
                    ),
            ),
            widget.onEdit == null
                ? Container()
                : isEditing
                    ? IconButton(
                        color: widget.color.adaptByLuminance(),
                        onPressed: () => setState(() => isEditing = false),
                        icon: const Icon(Icons.edit_off),
                      )
                    : IconButton(
                        color: widget.color.adaptByLuminance(),
                        onPressed: () => setState(() => isEditing = true),
                        icon: const Icon(Icons.edit),
                      ),
            widget.onDelete == null
                ? Container()
                : IconButton(
                    color: widget.color.adaptByLuminance(),
                    onPressed: () => widget.onDelete!.call(),
                    icon: const Icon(Icons.delete),
                  ),
          ],
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
