import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/file_system/models/cl_directory.dart';
import '../models/file_system/models/cl_directory_info.dart';
import '../models/file_system/providers/cl_directory_info.dart';

class StorageInfoEntry extends ConsumerWidget {
  const StorageInfoEntry({
    required this.label,
    required this.dirs,
    super.key,
    this.action,
  });
  final String label;
  final List<CLDirectory> dirs;
  final Widget? action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoListAsync = dirs
        .map(
          (dir) => ref.watch(dir.infoStream).whenOrNull(data: (data) => data),
        )
        .toList();
    CLDirectoryInfo? info;
    Widget? trailing;
    final infoReady = infoListAsync.every((element) => element != null);
    if (infoReady) {
      info = infoListAsync.reduce((a, b) => a! + b!);
      trailing = action;
    }
    return ListTile(
      title: Text(label),
      subtitle: Text(info?.statistics ?? ''),
      trailing: trailing,
    );
  }
}
