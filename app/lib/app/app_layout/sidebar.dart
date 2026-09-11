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
      'icon': Icons.dashboard,
      'color': Colors.purpleAccent,
      'route': "/monthly-report",
    },
    {
      'title': "Relatório anual",
      'icon': Icons.space_dashboard,
      'color': Colors.blueAccent,
      'route': "/yearly-report",
    },
    {
      'title': 'Prestação de contas',
      'icon': Icons.table_view,
      'color': Colors.lightGreen,
      'route': "/accountability",
    },
  ];

  int selectedPage = 0;
  bool isOpen = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: isOpen ? 300 : 56,
      shape: const ContinuousRectangleBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          navTitle(),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _pages.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                return isOpen ? itemFull(_pages[index], index) : itemShort(_pages[index], index);
              },
            ),
          ),
          IconButton(
            key: const Key('toggle-sidebar'),
            icon: Icon(isOpen ? Icons.arrow_left : Icons.arrow_right),
            onPressed: () {
              setState(() => isOpen = !isOpen);
            },
          ),
        ],
      ),
    );
  }

  Row navTitle() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Text(
            isOpen ? "Navegação" : "N",
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget itemFull(
    dynamic page,
    int pageIndex,
  ) {
    return ListTile(
      selected: pageIndex == selectedPage,
      selectedColor: Colors.black,
      selectedTileColor: Colors.white,
      minTileHeight: 56,
      leading: pageIcon(page),
      title: Text(page['title']),
      onTap: () => goToPage(pageIndex, page['route']),
    );
  }

  Widget itemShort(
    dynamic page,
    int pageIndex,
  ) {
    return ListTile(
      selected: pageIndex == selectedPage,
      selectedColor: Colors.black,
      selectedTileColor: Colors.white,
      contentPadding: EdgeInsets.all(0),
      horizontalTitleGap: 0,
      minLeadingWidth: 0,
      minTileHeight: 56,
      title: pageIcon(page),
      onTap: () => goToPage(pageIndex, page['route']),
    );
  }

  Widget pageIcon(dynamic page) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.outline,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          page['icon'],
          color: page['color'],
        ),
      ),
    );
  }

  void goToPage(int pageIndex, String route) {
    if (pageIndex == selectedPage) return;
    setState(() => selectedPage = pageIndex);
    context.go(route);
  }
}
