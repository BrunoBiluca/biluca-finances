import 'package:biluca_financas/app/app_layout/sidebar/sidebar.dart';
import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool fillAvailableHeight;

  const AppLayout({
    super.key,
    required this.child,
    this.fillAvailableHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1600),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: child,
        ),
      ),
    );

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sidebar(),
          Expanded(
            child: fillAvailableHeight
                ? content
                : SingleChildScrollView(child: content),
          ),
        ],
      ),
    );
  }
}
