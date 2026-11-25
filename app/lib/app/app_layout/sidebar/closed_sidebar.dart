import 'package:biluca_financas/app/app_layout/sidebar/sidebar_page.model.dart';
import 'package:biluca_financas/app/themes/app_colors.dart';
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
        Expanded(
          child: Semantics(
            label: sidebarNavigationLabel,
            container: true,
            explicitChildNodes: true,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: pages.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) => buildItem(context, index),
            ),
          ),
        )
      ],
    );
  }

  Widget buildItem(BuildContext context, int index) {
    var page = pages[index];
    var style = Theme.of(context).textTheme.bodyLarge;
    final isSelected = index == selectedPage;

    return Tooltip(
      message: page.title,
      excludeFromSemantics: true,
      child: Semantics(
        label: page.title,
        button: true,
        selected: isSelected,
        onTap: () => onSelectPage(index),
        child: ExcludeSemantics(
          child: ListTile(
            selected: isSelected,
            selectedColor: style?.color,
            selectedTileColor: context.appColors.sidebarHighlightBackground,
            contentPadding: EdgeInsets.all(0),
            title: SizedBox(
              height: 36,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appColors.sidebarHighlightBackground,
                ),
                child: Icon(
                  page.icon,
                  color: page.color,
                ),
              ),
            ),
            onTap: () => onSelectPage(index),
          ),
        ),
      ),
    );
  }
}
