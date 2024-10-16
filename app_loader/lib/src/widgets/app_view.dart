// ignore_for_file: public_member_api_docs, sort_constructors_first
// Reference : https://gist.github.com/onatcipli/aed0372c987b4ae32311fe32bb4c1209

import 'package:app_loader/src/widgets/app_theme.dart';
import 'package:colan_services/colan_services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/app_descriptor.dart';
import '../models/cl_route_descriptor.dart';

import 'bottom_nav_page.dart';

class AppView extends ConsumerStatefulWidget {
  const AppView({
    required this.appDescriptor,
    super.key,
  });
  final AppDescriptor appDescriptor;

  @override
  ConsumerState<AppView> createState() => _RaLRouterState();
}

class _RaLRouterState extends ConsumerState<AppView>
    with WidgetsBindingObserver {
  late GoRouter _router;
  final GlobalKey<NavigatorState> parentNavigatorKey =
      GlobalKey<NavigatorState>();
  static final List<GlobalKey<NavigatorState>> navigatorPageKeys = [];

  @override
  void initState() {
    for (final _ in widget.appDescriptor.shellRoutes) {
      navigatorPageKeys.add(GlobalKey<NavigatorState>());
    }
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //Does this work?
    if (state == AppLifecycleState.resumed) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.appDescriptor;

    /* final routes = app.screenBuilders.map(
      (e) => GoRoute(
        path: '/${e.name}',
        name: e.name,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: AppTheme(child: e.builder(context, state)),
          transitionsBuilder: app.transitionBuilder,
        ),
      ),
    ); */
    final fullScreenRoutes = app.fullscreenBuilders.map(
      (e) => GoRoute(
        path: '/${e.name}',
        name: e.name,
        parentNavigatorKey: parentNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: AppTheme(
            child: IncomingMediaMonitor(
              onMedia: app.incomingMediaViewBuilder,
              child: e.builder(context, state),
            ),
          ),
          transitionsBuilder: app.transitionBuilder,
        ),
      ),
    );

    final shellRoutes = app.shellRoutes.indexed.map((e) {
      final (index, route) = e;
      return StatefulShellBranch(
        navigatorKey: navigatorPageKeys[index],
        routes: [
          GoRoute(
            path: '/${route.name}',
            pageBuilder: (context, GoRouterState state) {
              return MaterialPage(
                key: state.pageKey,
                child: route.builder(context, state),
              );
            },
            routes: (index != 0)
                ? []
                : app.screenBuilders.map(
                    (e) {
                      return GoRoute(
                        path: e.name,
                        name: '${route.name}/${e.name}',
                        pageBuilder: (context, state) =>
                            CustomTransitionPage<void>(
                          key: state.pageKey,
                          child: AppTheme(child: e.builder(context, state)),
                          transitionsBuilder: app.transitionBuilder,
                        ),
                      );
                    },
                  ).toList(),
          ),
        ],
      );
    }).toList();

    _router = GoRouter(
      navigatorKey: parentNavigatorKey,
      initialLocation: '/${app.shellRoutes.first.name}',
      routes: [
        StatefulShellRoute.indexedStack(
          parentNavigatorKey: parentNavigatorKey,
          branches: shellRoutes,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return MaterialPage(
              child: BottomNavigationPage(
                onMedia: app.incomingMediaViewBuilder,
                routes: app.shellRoutes,
                child: navigationShell,
              ),
            );
          },
        ),
        ...fullScreenRoutes,
      ],
      redirect: (context, state) {
        return app.redirector(state.uri.path);
      },
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      //routeInformationProvider: _router.routeInformationProvider,
      //routeInformationParser: _router.routeInformationParser,
      routerConfig: _router,
      title: app.title,
    );
  }

  GoRoute getRoute({
    required String name,
    required CLWidgetBuilder builder,
    CLTransitionBuilder? transitionBuilder,
  }) {
    return GoRoute(
      path: '/$name',
      name: name,
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: builder(context, state),
        transitionsBuilder: transitionBuilder ?? defaultTransitionBuilder,
      ),
    );
  }

  static Widget defaultTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position:
          Tween(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
      child: child,
    );
  }
}

/* void printGoRouterState(GoRouterState state) {
  _infoLogger(' state: ${state.extra} ${state.error} ${state.fullPath}'
      ' ${state.uri} ${state.name} ${state.pageKey} ${state.pathParameters} '
      '${state.uri.queryParameters} ${state.path} ${state.matchedLocation}');
}

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
 */
