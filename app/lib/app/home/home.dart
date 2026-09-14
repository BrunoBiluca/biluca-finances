import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Biluca Finanças",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  " — ",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  "Controle de orçamentos pessoais",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 24),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text("Bem-vindo de volta! Aqui está um resumo executivo e a consolidação da sua saúde financeira."),
          ],
        ),
      ),
    );
  }
}
