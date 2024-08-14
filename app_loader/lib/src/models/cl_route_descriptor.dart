// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef CLWidgetBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
);

@immutable
class CLRouteDescriptor {
  const CLRouteDescriptor({
    required this.name,
    required this.builder,
  });
  final String name;
  final CLWidgetBuilder builder;
}

@immutable
class CLShellRouteDescriptor extends CLRouteDescriptor {
  final Icon iconData;
  final String? label;

  const CLShellRouteDescriptor({
    required super.name,
    required super.builder,
    required this.iconData,
    this.label,
  });
}
