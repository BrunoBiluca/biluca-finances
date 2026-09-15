import 'package:biluca_financas/app/app_layout/sidebar/sidebar_page.model.dart';
import 'package:flutter/material.dart';

class ClosedSidebar extends StatelessWidget {
  final List<SidebarPage> pages;
  final int selectedPage;
  final ValueChanged<int> onSelectPage;
  const ClosedSidebar({
    super.key,
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
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image(
                image: AssetImage('assets/logo.png'),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "N",
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
              var style = Theme.of(context).textTheme.bodyLarge;
              return ListTile(
                selected: index == selectedPage,
                selectedColor: style?.color,
                selectedTileColor: Color(0xFF262A34),
                contentPadding: EdgeInsets.all(0),
                title: SizedBox(
                  height: 36,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF262A34),
                    ),
                    child: Icon(
                      page.icon,
                      color: page.color,
                    ),
                  ),
                ),
                onTap: () => onSelectPage(index),
              );
            },
          ),
        )
      ],
    );
  }
}
