import 'package:biluca_financas/components/mouse_back_button_listener.dart';
import 'package:flutter/material.dart';

class BaseDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const BaseDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return MouseBackButtonListener(
      child: AlertDialog(
        actions: actions,
        content: content,
        title: Text(title),
      ),
    );
  }
}
