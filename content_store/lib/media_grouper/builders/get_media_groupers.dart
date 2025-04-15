/* import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/media_grouper.dart';

class GetMediaGroupers extends ConsumerWidget {
  const GetMediaGroupers({
    required this.tapName,
    required this.builder,
    super.key,
  });
  final String tapName;
  final Widget Function(GroupBy groupBy) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupBy = ref.watch(groupMethodProvider(tapName));
    return builder(groupBy);
  }
}
 */
