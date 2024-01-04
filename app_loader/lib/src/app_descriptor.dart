import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

typedef CLWidgetBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
);
typedef CLAppInitializer = Future<bool> Function(Ref ref);
typedef CLTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
);
typedef CLRedirector = Future<String?> Function(String location);

typedef IncomingMediaViewBuilder = Widget Function(
  BuildContext context,
  WidgetRef ref, {
  required Map<String, SupportedMediaType> sharedMedia,
  required Function() onDiscard,
})?;

abstract class AppDescriptor {
  String get title;
  Map<String, CLWidgetBuilder> get screenBuilders;
  CLAppInitializer get appInitializer;
  CLTransitionBuilder get transitionBuilder;
  CLRedirector get redirector;
  IncomingMediaViewBuilder get incomingMediaViewBuilder;
}
