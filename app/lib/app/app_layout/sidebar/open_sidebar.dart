import 'package:biluca_financas/app/app_layout/sidebar/sidebar_page.model.dart';
import 'package:flutter/material.dart';

class OpenSidebar extends StatelessWidget {
  final String appVersion;
  final List<SidebarPage> pages;
  final int selectedPage;
  final ValueChanged<int> onSelectPage;

  const OpenSidebar({
    super.key,
    required this.appVersion,
    required this.pages,
    required this.selectedPage,
    required this.onSelectPage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 20,
      children: [
        Row(spacing: 8, mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Image(
              image: AssetImage('assets/logo-full.png'),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
              child: Text(
                appVersion,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 16),
            Text(
              "Navegação".toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: pages.length,
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              var page = pages[index];
              return ListTile(
                selected: index == selectedPage,
                selectedColor: Theme.of(context).textTheme.bodyLarge?.color,
                selectedTileColor: Color(0xFF262A34),
                minTileHeight: 56,
                leading: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF262A34),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      page.icon,
                      color: page.color,
                    ),
                  ),
                ),
                title: Text(page.title),
                titleTextStyle: Theme.of(context).textTheme.bodyLarge,
                onTap: () => onSelectPage(index),
              );
            },
          ),
        ),
      ],
    );
  }
}
