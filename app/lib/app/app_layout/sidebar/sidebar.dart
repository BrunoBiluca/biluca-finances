import 'package:biluca_financas/app/app_layout/sidebar/closed_sidebar.dart';
import 'package:biluca_financas/app/app_layout/sidebar/open_sidebar.dart';
import 'package:biluca_financas/app/app_layout/sidebar/sidebar_page.model.dart';
import 'package:biluca_financas/core/preferences/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
    SidebarPage("Relatório do mês", "/monthly-report", Icons.dashboard,
        Colors.purpleAccent),
    SidebarPage("Relatório anual", "/yearly-report", Icons.space_dashboard,
        Colors.blueAccent),
    SidebarPage("Prestação de contas", "/accountability", Icons.table_view,
        Colors.lightGreen),
    SidebarPage("Identificações", "/identifications", Icons.category,
        Colors.orangeAccent),
    SidebarPage("Configurações", "/settings", Icons.settings, Colors.blueGrey),
  ];

  late final PreferencesService _preferences = GetIt.I<PreferencesService>();
  late bool isOpen = !_preferences.sidebarCollapsed;
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
    final selectedPage = _selectedPageForCurrentRoute;

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
              mainAxisAlignment:
                  isOpen ? MainAxisAlignment.end : MainAxisAlignment.center,
              children: [
                IconButton(
                  key: const Key('toggle-sidebar'),
                  tooltip: isOpen ? "Recolher barra lateral" : "Expandir barra lateral",
                  icon: Icon(isOpen ? Icons.arrow_left : Icons.arrow_right),
                  onPressed: () {
                    setState(() => isOpen = !isOpen);
                    _preferences.setSidebarCollapsed(!isOpen);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int get _selectedPageForCurrentRoute {
    final location = GoRouterState.of(context).uri.path;
    return _pages.indexWhere((page) => page.route == location);
  }

  void goToPage(int pageIndex) {
    if (pageIndex == _selectedPageForCurrentRoute) return;
    context.go(_pages[pageIndex].route);
  }
}
