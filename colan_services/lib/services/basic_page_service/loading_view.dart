import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingView extends ConsumerWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: CircularProgressIndicator());
  }
}

class LoadViewHidden extends ConsumerWidget {
  const LoadViewHidden({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}
