import 'package:biluca_financas/sidebar.dart';
import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
