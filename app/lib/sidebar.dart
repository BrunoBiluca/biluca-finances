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
  bool isOpen = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: isOpen ? 300 : 56,
      shape: const ContinuousRectangleBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
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
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _pages.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                var page = _pages[index];
                return isOpen
                    ? itemFull(
                        context,
                        page['icon'],
                        page['color'],
                        page['title'],
                        page['route'],
                        index,
                      )
                    : itemShort(
                        context,
                        page['icon'],
                        page['color'],
                        page['route'],
                        index,
                      );
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

  Widget itemFull(
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
      minTileHeight: 56,
      leading: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.outline,
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

  Widget itemShort(
    BuildContext context,
    IconData icon,
    Color iconColor,
    String route,
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
      title: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.outline,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
      ),
      onTap: () {
        if (pageIndex == selectedPage) return;
        setState(() => selectedPage = pageIndex);
        context.go(route);
      },
    );
  }
}
