import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/store.dart';

class GetStore extends ConsumerWidget {
  const GetStore({
    required this.builder,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
  });
  final Widget Function(ContentStore store) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
