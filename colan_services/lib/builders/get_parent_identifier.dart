import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

class GetParentIdentifier extends ConsumerWidget {
  const GetParentIdentifier({required this.builder, super.key});
  final Widget Function(String parentIdentifier) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identifier = ref.watch(mainPageIdentifierProvider);
    return builder(identifier);
  }
}
