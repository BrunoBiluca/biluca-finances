import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrimaryTextField extends StatefulWidget {
  final String labelText;
  final bool autofocus;
  final TextEditingController? controller;
  final Function()? onEditingComplete;
  final TextInputType? keyboardType;
  final bool validateEmpty;
  final List<TextInputFormatter> formatters;
  const PrimaryTextField({
    super.key,
    required this.labelText,
    this.autofocus = false,
    this.controller,
    this.keyboardType,
    this.onEditingComplete,
    this.validateEmpty = false,
    this.formatters = const [],
  });

  @override
  State<PrimaryTextField> createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  String? errorText;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.titleMedium;

    var inputBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: style?.color ?? Colors.white,
      ),
    );

    var errorInputBorder = const UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.purple,
      ),
    );

    return TextField(
      cursorColor: style?.color,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: errorText == null ? style : style?.copyWith(color: Colors.purple),
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        focusedErrorBorder: errorInputBorder,
        errorBorder: errorInputBorder,
        errorStyle: theme.textTheme.bodySmall?.copyWith(color: Colors.purple),
        errorText: errorText,
      ),
      autofocus: widget.autofocus,
      controller: controller,
      keyboardType: widget.keyboardType,
      onChanged: (value) {
        valide();
      },
      inputFormatters: widget.formatters,
      onTapOutside: (event) => valide(),
      onEditingComplete: widget.onEditingComplete,
    );
  }

  void valide() {
    if (!widget.validateEmpty) {
      return;
    }

    setState(() {
      errorText = null;
      if (controller.text.isEmpty) {
        errorText = 'Preencha o campo, por favor';
      }
    });
  }
}
