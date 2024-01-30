// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_descriptor.dart';

import 'pages/page_incoming_media.dart';
import 'providers/incoming_media.dart';

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
  static final GlobalKey<NavigatorState> parentNavigatorKey =
      GlobalKey<NavigatorState>();
  static final List<GlobalKey<NavigatorState>> navigatorPageKeys = [
    for (var i = 0; i < 3; i++) GlobalKey<NavigatorState>(),
  ];
  static Page<dynamic> getPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return MaterialPage(
      key: state.pageKey,
      child: child,
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FocusScope.of(context).unfocus();
    }
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
        child:
            builder(context, state), //const AppTheme(child: LogOutUserPage()),
        transitionsBuilder: transitionBuilder ?? defaultTransitionBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.appDescriptor;
    final routes = <GoRoute>[];

    app.screenBuilders.forEach(
      (name, screenBuilder) => routes.add(
        getRoute(
          name: name,
          builder: screenBuilder,
          transitionBuilder: app.transitionBuilder,
        ),
      ),
    );

    _infoLogger('RaLRouter.build ${app.screenBuilders.length}');
    final routePaths = app.screenBuilders.keys.map((e) => '/$e').toList();
    final routeName = app.screenBuilders.keys.map((e) => e).toList();
    _router = GoRouter(
      navigatorKey: parentNavigatorKey,
      routes: [
        StatefulShellRoute.indexedStack(
          parentNavigatorKey: parentNavigatorKey,
          branches: [
            for (int i = 0; i < 3; i++)
              StatefulShellBranch(
                navigatorKey: navigatorPageKeys[i],
                routes: [
                  GoRoute(
                    path: routePaths[i],
                    pageBuilder: (context, GoRouterState state) {
                      return getPage(
                        child:
                            app.screenBuilders[routeName[i]]!(context, state),
                        state: state,
                      );
                    },
                  ),
                ],
              ),
          ],
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return MaterialPage(
              key: state.pageKey,
              child: BottomNavigationPage(
                child: navigationShell,
              ),
            );
          },
        ),
        ...routes.sublist(2),
        GoRoute(
          path: '/incoming',
          name: 'incoming',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: PageIncomingMedia(
              builder: app.incomingMediaViewBuilder,
            ), //const AppTheme(child: LogOutUserPage()),
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
      ],
      redirect: (context, GoRouterState state) async {
        final hasIncomingMedia = ref.watch(incomingMediaProvider).isNotEmpty;
        if (hasIncomingMedia) {
          if (state.matchedLocation == '/incoming') return null;
          return '/incoming';
        }

        return app.redirector.call(state.uri.toString());
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

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({
    required this.child,
    super.key,
  });

  final StatefulNavigationShell child;

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CLBackground(
        child: SafeArea(
          child: widget.child,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: widget.child.currentIndex,
        onTap: (index) {
          widget.child.goBranch(
            index,
            initialLocation: index == widget.child.currentIndex,
          );
          setState(() {});
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings',
          ),
        ],
      ),
    );
  }
}
