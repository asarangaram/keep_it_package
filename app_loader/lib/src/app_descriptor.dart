import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cl_route_descriptor.dart';

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
  required CLMediaInfoGroup media,
  required void Function() onDiscard,
  required void Function(int collectionID) onAccept,
});

abstract class AppDescriptor {
  String get title;
  List<CLRouteDescriptor> get screenBuilders;
  List<CLRouteDescriptor> get fullscreenBuilders;
  List<CLShellRouteDescriptor> get shellRoutes;
  CLAppInitializer get appInitializer;
  CLTransitionBuilder get transitionBuilder;
  CLRedirector get redirector;
  IncomingMediaViewBuilder get incomingMediaViewBuilder;
}
