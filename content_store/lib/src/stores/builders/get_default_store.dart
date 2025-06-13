import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'get_registerred_urls.dart';
import 'get_store.dart';

class GetDefaultStore extends ConsumerWidget {
  const GetDefaultStore({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });

  final Widget Function(CLStore) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetRegisterredURLs(
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
        builder: (registerredURLs) {
          return GetStore(
            storeURL: registerredURLs.defaultStoreURL,
            builder: builder,
            errorBuilder: errorBuilder,
            loadingBuilder: loadingBuilder,
          );
        });
  }
}
