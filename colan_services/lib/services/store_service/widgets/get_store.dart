import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/store.dart';

class GetStore extends ConsumerWidget {
  const GetStore({required this.builder, super.key});
  final Widget Function(Store storeInstance) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShowAsyncValue<Store>(
      ref.watch(storeProvider),
      builder: builder,
    );
  }
}
