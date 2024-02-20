// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

@immutable
class DeviceDirectories {
  final Directory docDir;
  final Directory cacheDir;
  const DeviceDirectories({
    required this.docDir,
    required this.cacheDir,
  });
}

class WhenDeviceDirectoriesAccessible extends ConsumerWidget {
  const WhenDeviceDirectoriesAccessible({required this.builder, super.key});
  final Widget Function(DeviceDirectories dirs) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docDirAsync = ref.watch(docDirProvider);
    return docDirAsync.when(
      data: builder,
      error: (error, stackTrace) => CLErrorView(errorMessage: error.toString()),
      loading: CLLoadingView.new,
    );
  }
}

final docDirProvider = FutureProvider<DeviceDirectories>((ref) async {
  return DeviceDirectories(
    docDir: await getApplicationDocumentsDirectory(),
    cacheDir: await getApplicationCacheDirectory(),
  );
});
