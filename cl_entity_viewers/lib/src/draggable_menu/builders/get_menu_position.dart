import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/menu_position.dart';

class GetMenuPosition extends ConsumerWidget {
  const GetMenuPosition({required this.builder, super.key});
  final Widget Function(
    Offset menuPosition, {
    required void Function(Offset offset) onUpdateMenuPosition,
  }) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuPosition = ref.watch(
      menuPositionNotifierProvider.select((value) => value.menuPosition),
    );
    return builder(
      menuPosition,
      onUpdateMenuPosition: (offset) {
        ref.read(menuPositionNotifierProvider.notifier).setMenuPosition(offset);
      },
    );
  }
}
