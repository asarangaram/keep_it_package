import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/network_scanner.dart';
import '../providers/scanner.dart';

class GetNetworkScanner extends ConsumerWidget {
  const GetNetworkScanner({
    required this.builder,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
  });
  final Widget Function(NetworkScanner store) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanner = ref.watch(networkScannerProvider);
    return builder(scanner);
  }
}
