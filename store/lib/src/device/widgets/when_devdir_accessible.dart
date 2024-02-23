import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device_directories.dart';
import '../providers/device_directories.dart';

class GetDeviceDirectories extends ConsumerWidget {
  const GetDeviceDirectories({required this.builder, super.key});
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
