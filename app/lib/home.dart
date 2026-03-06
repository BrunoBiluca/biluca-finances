import 'package:biluca_financas/components/base_page.dart';
import 'package:biluca_financas/reports/monthly_report/current_month_report.dart';
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
      body: const BasePage(
        child: CurrentMonthReport(),
      ),
    );
  }
}
