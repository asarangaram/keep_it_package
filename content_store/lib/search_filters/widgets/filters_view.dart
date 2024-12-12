import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/filters.dart';

class ShowOrHideSearchOption extends ConsumerWidget {
  const ShowOrHideSearchOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(filtersProvider.select((e) => e.editing));

    return CLButtonIcon.small(
      isEditing ? clIcons.searchOpened : clIcons.searchRequest,
      onTap: () => ref.read(filtersProvider.notifier).toggleEdit(),
    );
  }
}

class SearchOptions extends ConsumerWidget {
  const SearchOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(filtersProvider.select((e) => e.editing));
    return AnimateSearchOptions(
      child: Card(
        elevation: 8,
        color: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(2), // Adjust the border radius as needed
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Clear Search',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: CLButtonIcon.tiny(
                      isExpanded
                          ? Icons.arrow_drop_down_sharp
                          : Icons.arrow_drop_up_sharp,
                      onTap: () =>
                          ref.read(filtersProvider.notifier).toggleEdit(),
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              const Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AddNewFilter(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AddNewFilter extends StatelessWidget {
  const AddNewFilter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Indicator
            CircleAvatar(
              radius: 12,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.add_circle,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Center(
              child: Text(
                'New Search Option',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class AnimateSearchOptions extends ConsumerStatefulWidget {
  const AnimateSearchOptions({required this.child, super.key});
  final Widget child;

  @override
  AnimatedHeightWidgetState createState() => AnimatedHeightWidgetState();
}

class AnimatedHeightWidgetState extends ConsumerState<AnimateSearchOptions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: child,
            );
          },
          child: widget.child,
        ),
      ],
    );
  }
}
