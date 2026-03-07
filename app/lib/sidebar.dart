import 'package:biluca_financas/accountability/page.dart';
import 'package:biluca_financas/home.dart';
import 'package:biluca_financas/reports/monthly_report/current_month_report.dart';
import 'package:biluca_financas/reports/monthly_report_v2/monthly_report_v2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({
    super.key,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final List<dynamic> _pages = [
    {
      'title': 'Home',
      'icon': Icons.home,
      'color': Colors.purpleAccent,
      'fac': () {
        return Home();
      }
    },
    {
      'title': 'Relatório do mês',
      'icon': Icons.home,
      'color': Colors.purpleAccent,
      'fac': () {
        return CurrentMonthReport();
      }
    },
    {
      'title': 'Relatório do mês (Novo)',
      'icon': Icons.home,
      'color': Colors.purpleAccent,
      'fac': () {
        return MonthlyReportV2();
      }
    },
    {
      'title': 'Prestação de contas',
      'icon': Icons.home,
      'color': Colors.lightGreen,
      'fac': () {
        return AccountabilityPage();
      }
    },
  ];

  int selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const ContinuousRectangleBorder(),
      child: ListView(padding: EdgeInsets.zero, children: <Widget>[
        ListTile(
          title: Text(
            'Navegação',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        ..._pages.mapIndexed(
            (index, page) => item(context, page['icon'], page['color'], page['title'], page['fac'](), index)),
      ]),
    );
  }

  ListTile item(BuildContext context, IconData icon, Color iconColor, String text, Widget widget, int pageIndex) {
    return ListTile(
      selected: pageIndex == selectedPage,
      selectedColor: Colors.black,
      selectedTileColor: Colors.white,
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
      onTap: () {
        if (pageIndex == selectedPage) return;
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => widget),
        );
        setState(() => selectedPage = pageIndex);
      },
    );
  }
}
