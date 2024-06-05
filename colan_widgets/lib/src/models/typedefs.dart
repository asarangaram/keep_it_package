import 'package:flutter/material.dart';

typedef QuickMenuScopeKey = GlobalKey<State<StatefulWidget>>;
typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  T item, {
  required QuickMenuScopeKey quickMenuScopeKey,
});
