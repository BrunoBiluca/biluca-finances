import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TextBallon extends StatefulWidget {
  final String text;
  final Color color;
  final Function(String, Color)? onEdit;
  final VoidCallback? onDelete;
  final EdgeInsets padding;

  const TextBallon({
    super.key,
    required this.text,
    required this.color,
    this.onEdit,
    this.onDelete,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                        Icon(Icons.shop, color: textColor()),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            controller: cont,
                            cursorColor: textColor(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor()),
                            onEditingComplete: () {
                              setState(() {
                                widget.onEdit!.call(cont.text, widget.color);
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
                                          widget.onEdit!.call(widget.text, editColor);
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
                        Icon(Icons.shop, color: textColor()),
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
}
