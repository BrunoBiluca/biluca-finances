import 'package:biluca_financas/main_drawner.dart';
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
        title: Text(
          'Biluca Finanças',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: Row(
        children: [
          const SizedBox(
            width: 250,
            child: MainDrawner(),
          ),
          Expanded(child: Container()),
          const SizedBox(
            width: 1800,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CurrentMonthReport(),
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
