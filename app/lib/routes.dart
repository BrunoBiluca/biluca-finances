import 'package:biluca_financas/accountability/page.dart';
import 'package:biluca_financas/app_layout.dart';
import 'package:biluca_financas/home.dart';
import 'package:biluca_financas/main.dart';
import 'package:biluca_financas/reports/monthly_report_v2/monthly_report_v2.dart';
import 'package:biluca_financas/reports/yearly_report/yearly_report.dart';
import 'package:go_router/go_router.dart';

GoRouter routes() {
  return GoRouter(
    initialLocation: '/',
    navigatorKey: navigatorKey,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Home(),
          ),
          GoRoute(
            path: '/accountability',
            builder: (context, state) => const AccountabilityPage(),
          ),
          GoRoute(
            path: '/monthly-report',
            builder: (context, state) => const MonthlyReportV2(),
          ),
          GoRoute(
            path: '/yearly-report',
            builder: (context, state) => const YearlyReport(),
          )
        ],
      ),
    ],
  );
}
