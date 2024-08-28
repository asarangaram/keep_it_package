import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/p2_db_manager.dart';

class GetStore extends ConsumerWidget {
  const GetStore({required this.builder, super.key});
  final Widget Function(Store storeInstance) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShowAsyncValue<StoreManager>(
      ref.watch(storeProvider),
      builder: (storeManager) => builder(storeManager.store),
    );
  }
}
