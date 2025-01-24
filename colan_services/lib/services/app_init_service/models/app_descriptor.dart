import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../incoming_media_service/models/cl_shared_media.dart';
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
  BuildContext context, {
  required CLMediaFileGroup incomingMedia,
  required void Function({required bool result}) onDiscard,
});

abstract class AppDescriptor {
  String get title;

  List<CLRouteDescriptor> get screens;

  CLAppInitializer get appInitializer;
  CLTransitionBuilder get transitionBuilder;
  CLRedirector get redirector;
  IncomingMediaViewBuilder get incomingMediaViewBuilder;
}
