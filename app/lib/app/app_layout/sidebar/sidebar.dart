import 'package:biluca_financas/app/app_layout/sidebar/closed_sidebar.dart';
import 'package:biluca_financas/app/app_layout/sidebar/open_sidebar.dart';
import 'package:biluca_financas/app/app_layout/sidebar/sidebar_page.model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({
    super.key,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final List<SidebarPage> _pages = [
    SidebarPage("Home", "/", Icons.home, Colors.purpleAccent),
    SidebarPage("Relatório do mês", "/monthly-report", Icons.dashboard, Colors.purpleAccent),
    SidebarPage("Relatório anual", "/yearly-report", Icons.space_dashboard, Colors.blueAccent),
    SidebarPage("Prestação de contas", "/accountability", Icons.table_view, Colors.lightGreen),
  ];

  int selectedPage = 0;
  bool isOpen = true;
  late String appVersion = "";

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: isOpen ? 300 : 68,
      shape: const ContinuousRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            Expanded(
              child: isOpen
                  ? OpenSidebar(
                      appVersion: appVersion,
                      pages: _pages,
                      selectedPage: selectedPage,
                      onSelectPage: goToPage,
                    )
                  : ClosedSidebar(
                      pages: _pages,
                      selectedPage: selectedPage,
                      onSelectPage: goToPage,
                    ),
            ),
            Row(
              mainAxisAlignment: isOpen ? MainAxisAlignment.end : MainAxisAlignment.center,
              children: [
                IconButton(
                  key: const Key('toggle-sidebar'),
                  icon: Icon(isOpen ? Icons.arrow_left : Icons.arrow_right),
                  onPressed: () {
                    setState(() => isOpen = !isOpen);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void goToPage(int pageIndex) {
    if (pageIndex == selectedPage) return;
    setState(() => selectedPage = pageIndex);
    context.go(_pages[pageIndex].route);
  }
}
