import 'package:content_store/src/stores/providers/active_store_provider.dart';
import 'package:content_store/src/stores/providers/network_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class GetStoreStatus extends ConsumerWidget {
  const GetStoreStatus({required this.builder, super.key});

  final Widget Function(
      {required bool isConnected,
      required AsyncValue<CLStore> storeAsync}) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanner = ref.watch(networkScannerProvider);
    if (!scanner.lanStatus) {
      return builder(
          isConnected: scanner.lanStatus, storeAsync: const AsyncLoading());
    } else {
      final storeAsync = ref.watch(activeStoreProvider);
      return builder(isConnected: scanner.lanStatus, storeAsync: storeAsync);
    }
  }
}
