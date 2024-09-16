import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/downloader.dart';

class DownloaderProgressbar extends ConsumerWidget {
  const DownloaderProgressbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloaderStatusAsync = ref.watch(downloaderStatusProvider);
    final colors = <Color>[
      Colors.green,
      Colors.blue,
      Colors.grey,
    ];
    const height = 10.0;
    return downloaderStatusAsync.when(
      data: (downloaderStatus) {
        if (downloaderStatus.total == 0) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final (i, val) in [
                downloaderStatus.completed,
                downloaderStatus.running,
                downloaderStatus.waiting,
              ].indexed)
                Expanded(
                  flex: val,
                  child: Container(
                    color: colors[i],
                  ),
                ),
            ],
          ),
        );
      },
      error: (_, __) => const SizedBox.shrink(),
      loading: SizedBox.shrink,
    );
  }
}
