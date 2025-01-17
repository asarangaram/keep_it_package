import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorView extends ConsumerWidget {
  const ErrorView({
    required this.error,
    required this.stackTrace,
    super.key,
  });
  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Placeholder();
  }
}

class ErrorViewHidden extends ConsumerWidget {
  const ErrorViewHidden({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}
