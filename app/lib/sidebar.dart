import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      'route': '/',
    },
    {
      'title': 'Relatório do mês',
      'icon': Icons.home,
      'color': Colors.purpleAccent,
      'route': "/monthly-report",
    },
    {
      'title': 'Prestação de contas',
      'icon': Icons.home,
      'color': Colors.lightGreen,
      'route': "/accountability",
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
          (index, page) => item(
            context,
            page['icon'],
            page['color'],
            page['title'],
            page['route'],
            index,
          ),
        ),
      ]),
    );
  }

  ListTile item(
    BuildContext context,
    IconData icon,
    Color iconColor,
    String text,
    String route,
    int pageIndex,
  ) {
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
        setState(() => selectedPage = pageIndex);
        context.go(route);
      },
    );
  }
}
