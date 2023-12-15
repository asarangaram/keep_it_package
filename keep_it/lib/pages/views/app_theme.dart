import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTheme extends ConsumerWidget {
  const AppTheme({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(data: Theme.of(context).copyWith(), child: child);
  }
}
