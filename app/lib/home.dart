import 'package:biluca_financas/accountability/page.dart';
import 'package:biluca_financas/reports/current_month_report.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biluca Finanças'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountabilityPage(),
                ),
              ).whenComplete(
                () => setState(() {}),
              ),
              child: const Text('Prestação de Contas'),
            ),
            const SizedBox(height: 20),
            Expanded(child: CurrentMonthReport()),
          ],
        ),
      ),
    );
  }
}
