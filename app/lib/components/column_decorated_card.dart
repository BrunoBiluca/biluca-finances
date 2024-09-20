import 'package:biluca_financas/components/base_decorated_card.dart';
import 'package:flutter/material.dart';

class ColumnDecoratedCard extends StatelessWidget {
  final String title;
  final Future<dynamic> future;
  final Widget Function(dynamic) child;

  const ColumnDecoratedCard({super.key, required this.title, required this.future, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }

        var data = snapshot.data;
        if (data == null) {
          return const Text("Nenhum item encontrado");
        }

        return BaseDecoratedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 20),
              Expanded(child: child(data)),
            ],
          ),
        );
      },
    );
  }
}
