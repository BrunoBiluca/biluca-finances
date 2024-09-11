import 'package:biluca_financas/accountability/page.dart';
import 'package:flutter/material.dart';

class MainDrawner extends StatelessWidget {
  const MainDrawner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const ContinuousRectangleBorder(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(
            title: Text(
              'Navegação',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          item(
            context,
            Icons.home,
            Colors.purpleAccent,
            "Relatório do mês",
            () {},
          ),
          item(
            context,
            Icons.table_view,
            Colors.greenAccent,
            "Prestação de contas",
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountabilityPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ListTile item(BuildContext context, IconData icon, Color iconColor, String text, Function() action) {
    return ListTile(
      leading: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
      ),
      title: Text(text),
      onTap: action,
    );
  }
}
