import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/filterred_media.dart';

class GetFilterredMediaByPass extends ConsumerWidget {
  const GetFilterredMediaByPass({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.incoming,
    super.key,
  });
  final Widget Function(CLMedias filterredMedia) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final CLMedias incoming;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final filterred = ref.watch(filterredMediaProvider(incoming));
    return builder(incoming);
  }
}
