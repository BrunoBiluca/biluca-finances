import 'package:biluca_financas/app/app_layout/sidebar.dart';
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1600,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
