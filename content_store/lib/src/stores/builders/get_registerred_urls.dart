import 'package:content_store/src/stores/models/registerred_urls.dart';
import 'package:content_store/src/stores/providers/registerred_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetRegisterredURLs extends ConsumerWidget {
  const GetRegisterredURLs({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });

  final Widget Function(RegisteredURLs availableStores) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerredURLsAsync = ref.watch(registeredURLsProvider);

    return registerredURLsAsync.when(
      data: builder,
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
