import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/app_theme.dart';

class EmptyViewCollection extends ConsumerWidget {
  const EmptyViewCollection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppTheme(
      child: Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (List v in [
              [Icons.menu, "Suggested\nCollections"],
              [Icons.menu, "New\nCollection"],
            ])
              Expanded(
                child: ElevatedIconLabelled(
                  child: CLIconLabelled.large(
                    (v)[0],
                    (v)[1],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ElevatedIconLabelled extends StatelessWidget {
  const ElevatedIconLabelled({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: CLScaleType.large.fontSize * 8,
        height: CLScaleType.large.fontSize * 10,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: Card(
                elevation: 12,
                shape: const ContinuousRectangleBorder(),
                margin: const EdgeInsets.all(0),
                child: InkWell(
                  onTap: () {},
                  child: Align(
                    alignment: Alignment.center,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
/*

child: 
                     */