import 'package:biluca_financas/app/accountability_identifications/widgets/identification_modal_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class IdentificationColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const IdentificationColorPickerDialog({super.key, required this.initialColor});

  static Future<Color?> show(BuildContext context, Color initialColor) {
    return showDialog<Color>(
      context: context,
      builder: (context) =>
          IdentificationColorPickerDialog(initialColor: initialColor),
    );
  }

  @override
  State<IdentificationColorPickerDialog> createState() =>
      _IdentificationColorPickerDialogState();
}

class _IdentificationColorPickerDialogState
    extends State<IdentificationColorPickerDialog> {
  late Color _color;
  late final TextEditingController _hexController;
  String? _hexError;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
    _hexController = TextEditingController(text: _hex(_color));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _hex(Color color) {
    final value = color
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
    return '#$value';
  }

  Color? _parseHex(String value) {
    final normalized = value.replaceAll('#', '').trim();
    if (normalized.length != 6) return null;
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) return null;
    return Color(0xFF000000 | parsed);
  }

  void _onHexChanged(String value) {
    final parsed = _parseHex(value);
    setState(() {
      _hexError = parsed == null ? 'Informe uma cor no formato #RRGGBB' : null;
      if (parsed != null) _color = parsed;
    });
  }

  void _save() {
    final parsed = _parseHex(_hexController.text);
    if (parsed == null) {
      setState(() => _hexError = 'Informe uma cor no formato #RRGGBB');
      return;
    }
    Navigator.of(context).pop(_color);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cor da categoria'),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorPicker(
                pickerColor: _color,
                onColorChanged: (color) {
                  setState(() {
                    _color = color;
                    _hexController.text = _hex(color);
                    _hexController.selection = TextSelection.collapsed(
                      offset: _hexController.text.length,
                    );
                  });
                },
                enableAlpha: false,
                portraitOnly: true,
                pickerAreaHeightPercent: 0.45,
                hexInputBar: false,
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('identification-color-hex-field'),
                controller: _hexController,
                onChanged: _onHexChanged,
                decoration: identificationModalFieldDecoration(
                  context,
                  labelText: 'Cor hexadecimal',
                  hintText: '#RRGGBB',
                  errorText: _hexError,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          key: const Key('identification-color-save'),
          onPressed: _save,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
