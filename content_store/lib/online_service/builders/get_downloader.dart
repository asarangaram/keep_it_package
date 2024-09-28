import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/downloader_status.dart';
import '../providers/downloader_status.dart';

class GetDownloaderStatus extends ConsumerWidget {
  const GetDownloaderStatus({
    required this.builder,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
  });
  final Widget Function(DownloaderStatus downloaderStatus) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadStatus = ref.watch(downloaderStatusProvider);
    return builder(downloadStatus);
  }
}
