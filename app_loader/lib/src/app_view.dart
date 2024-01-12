// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_descriptor.dart';
import 'app_logger.dart';
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

class _RaLRouterState extends ConsumerState<AppView> {
  late GoRouter _router;

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

    _infoLogger('RaLRouter.build');
    _router = GoRouter(
      routes: [
        ...routes,
        GoRoute(
          path: '/incoming',
          name: 'incoming',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: PageIncomingMedia(
              builder: app.incomingMediaViewBuilder,
            ), //const AppTheme(child: LogOutUserPage()),
            transitionsBuilder: defaultTransitionBuilder,
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

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
