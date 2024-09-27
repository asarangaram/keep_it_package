import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetPreviewUri extends ConsumerWidget {
  const GetPreviewUri({
    required this.id,
    required this.builder,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
  });
  final int id;
  final Widget Function(Uri uri) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: loadingBuilder?.call() ?? const CircularProgressIndicator(),
    );
  }
}
