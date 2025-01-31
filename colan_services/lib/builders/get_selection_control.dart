import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

class GetSelectionControl extends ConsumerWidget {
  const GetSelectionControl({
    required this.builder,
    required this.incoming,
    super.key,
    this.onSelectionChanged,
  });
  final Widget Function(
    CLSelector selector, {
    required void Function(List<CLEntity>? candidates, {bool? deselect})
        onUpdateSelection,
  }) builder;
  final List<CLEntity> incoming;
  final void Function(List<CLEntity>)? onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        selectorProvider.overrideWith((ref) => SelectorNotifier(incoming)),
        menuControlNotifierProvider
            .overrideWith((ref) => MenuControlNotifier()),
      ],
      child: GetSelection0(
        builder: builder,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
}

class GetSelection0 extends ConsumerWidget {
  const GetSelection0({
    required this.builder,
    super.key,
    this.onSelectionChanged,
  });
  final Widget Function(
    CLSelector selector, {
    required void Function(List<CLEntity>? candidates, {bool? deselect})
        onUpdateSelection,
  }) builder;
  final void Function(List<CLEntity>)? onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(selectorProvider, (prev, curr) {
      onSelectionChanged?.call(curr.items.toList());
    });
    final selector = ref.watch(selectorProvider);
    return builder(
      selector,
      onUpdateSelection: (candidates, {bool? deselect}) {
        if (candidates == null) {
          ref.read(selectorProvider.notifier).clear();
        } else if (deselect == null) {
          ref.read(selectorProvider.notifier).toggle(candidates);
        } else if (deselect) {
          ref.read(selectorProvider.notifier).deselect(candidates);
        } else {
          ref.read(selectorProvider.notifier).select(candidates);
        }
      },
    );
  }
}
