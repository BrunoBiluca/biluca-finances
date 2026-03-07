import 'package:biluca_financas/components/base_page.dart';
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
    return const BasePage(
      child: Text("Biluca Finanças é um aplicativo para controle de orçamentos pessoais."),
    );
  }
}
