import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/downloader_status.dart';
import '../providers/downloader.dart';

class GetDownloaderStatus extends ConsumerWidget {
  const GetDownloaderStatus({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(DownloaderStatus downloaderStatus) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadStatus = ref.watch(downloaderProvider);
    return builder(downloadStatus);
  }
}
