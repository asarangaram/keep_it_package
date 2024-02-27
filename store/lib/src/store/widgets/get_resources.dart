import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/resources.dart';
import '../providers/db_updater.dart';
import '../providers/resources.dart';

class GetResources extends ConsumerWidget {
  const GetResources({required this.builder, super.key});
  final Widget Function(Resources resources, {void Function()? onNewMedia})
      builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(resourcesProvider);
    return resourcesAsync.when(
      data: (res) => builder(
        res,
        onNewMedia: () {
          ref.read(dbUpdaterNotifierProvider.notifier).refreshProviders();
        },
      ),
      error: (error, stackTrace) => CLErrorView(errorMessage: error.toString()),
      loading: CLLoadingView.new,
    );
  }
}
