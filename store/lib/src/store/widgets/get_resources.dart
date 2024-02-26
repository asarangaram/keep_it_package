import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/src/store/providers/db_providers.dart';

import '../models/resources.dart';

class GetResources extends ConsumerWidget {
  const GetResources({required this.builder, super.key});
  final Widget Function(Resources resources) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(resourcesProvider);
    return resourcesAsync.when(
      data: builder,
      error: (error, stackTrace) => CLErrorView(errorMessage: error.toString()),
      loading: CLLoadingView.new,
    );
  }
}
