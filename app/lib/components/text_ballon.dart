import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TextBallon extends StatefulWidget {
  final String text;
  final Color color;
  final Function(String, Color)? onEdit;
  final VoidCallback? onDelete;

  const TextBallon({
    super.key,
    required this.text,
    required this.color,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<TextBallon> createState() => _TextBallonState();
}

class _TextBallonState extends State<TextBallon> {
  bool isEditing = false;

  Color textColor() {
    return widget.color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    var cont = TextEditingController(text: widget.text);
    return DecoratedBox(
      decoration: BoxDecoration(color: widget.color, borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: isEditing
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            controller: cont,
                            style: TextStyle(color: textColor()),
                            onEditingComplete: () {
                              setState(() {
                                widget.onEdit!.call(cont.text, widget.color);
                                isEditing = false;
                              });
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Editar Texto'),
                                content: Column(
                                  children: [
                                    ColorPicker(
                                      pickerColor: Colors.black,
                                      onColorChanged: (color) {
                                        setState(() {
                                          widget.onEdit!.call(widget.text, color);
                                          isEditing = false;
                                        });
                                      },
                                    ),
                                    ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Salvar"))
                                  ],
                                ),
                              ),
                            );
                          },
                          child: const Text('Cor'),
                        ),
                      ],
                    )
                  : Text(
                      widget.text,
                      style: TextStyle(color: textColor()),
                    ),
            ),
            widget.onEdit == null
                ? Container()
                : IconButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    icon: const Icon(Icons.edit),
                  ),
            widget.onDelete == null
                ? Container()
                : IconButton(
                    onPressed: () => widget.onDelete!.call(),
                    icon: const Icon(Icons.delete),
                  ),
          ],
        ),
      ),
    );
  }
}
