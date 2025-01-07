import 'package:go_router/go_router.dart';
import 'package:todo_app/explore/view/explore_page.dart';
import 'package:todo_app/home/view/home_page.dart';
import 'package:todo_app/stats/view/stats_page.dart';
import 'package:todo_app/todos_overview/view/todos_overview_page.dart';

enum AppRoute {
  home,
  stats,
  explore,
  todos,
}

final goRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomePage(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TodosOverviewPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: StatsPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ExplorePage(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
