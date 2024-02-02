// ignore_for_file: public_member_api_docs, sort_constructors_first
// Reference : https://gist.github.com/onatcipli/aed0372c987b4ae32311fe32bb4c1209

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_descriptor.dart';
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
    widget.appDescriptor.shellRoutes
        .forEach((_, __) => navigatorPageKeys.add(GlobalKey<NavigatorState>()));
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

    final routes = app.screenBuilders.entries.map(
      (e) => getRoute(
        name: e.key,
        builder: e.value,
        transitionBuilder: app.transitionBuilder,
      ),
    );

    final shellRoutes = app.shellRoutes.entries.indexed.map((e) {
      final (index, routes) = e;
      return StatefulShellBranch(
        navigatorKey: navigatorPageKeys[index],
        routes: [
          GoRoute(
            path: '/${routes.key}',
            pageBuilder: (context, GoRouterState state) {
              return MaterialPage(
                child: routes.value(context, state),
              );
            },
          ),
        ],
      );
    }).toList();

    _infoLogger('RaLRouter.build ${app.screenBuilders.length}');

    _router = GoRouter(
      navigatorKey: parentNavigatorKey,
      initialLocation: '/${app.shellRoutes.keys.first}',
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
              key: state.pageKey, // TODO(anandas): This seems causing issues!
              child: BottomNavigationPage(
                incomingMediaViewBuilder: app.incomingMediaViewBuilder,
                child: navigationShell,
              ),
            );
          },
        ),
        ...routes,
      ],
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
        // key: state.pageKey,
        child:
            builder(context, state), //const AppTheme(child: LogOutUserPage()),
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

void printGoRouterState(GoRouterState state) {
  _infoLogger(' state: ${state.extra} ${state.error} ${state.fullPath}'
      ' ${state.uri} ${state.name} ${state.pageKey} ${state.pathParameters} '
      '${state.uri.queryParameters} ${state.path} ${state.matchedLocation}');
}

bool _disableInfoLogger = false;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
