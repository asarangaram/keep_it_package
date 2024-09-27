import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetMediaUri extends ConsumerWidget {
  const GetMediaUri({
    required this.id,
    required this.builder,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
    this.nullOnError = false,
  });
  final int id;
  final bool nullOnError;
  final Widget Function(Uri? uri) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (nullOnError) return builder(null);
    return Center(
      child: loadingBuilder?.call() ?? const CircularProgressIndicator(),
    );
  }
}
