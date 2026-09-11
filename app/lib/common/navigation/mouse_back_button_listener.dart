import 'package:flutter/material.dart';

class MouseBackButtonListener extends StatelessWidget {
  final Widget child;

  const MouseBackButtonListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => onBackButtonPressed(event, context),
      child: child,
    );
  }

  void onBackButtonPressed(PointerDownEvent event, BuildContext context) {
    var mouseBackButtonValue = 8;
    if (event.buttons != mouseBackButtonValue) return;

    Navigator.pop(context);
  }
}
