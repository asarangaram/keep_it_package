import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});
  static Widget? cache;
  static Widget? pageCache;

  @override
  Widget build(BuildContext context) {
    if (!FullscreenLayout.foundInContext(context)) {
      return FullscreenLayout(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(
                  child: Center(
                    child: CLText.large(
                      'Empty',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (context.canPop())
                      CLButtonIcon.large(
                        MdiIcons.arrowLeft,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    CLButtonIcon.large(
                      MdiIcons.home,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ].map((e) => Expanded(child: Center(child: e))).toList(),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return cache ??= const Center(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: CLText.large(
          'Empty',
        ),
      ),
    );
  }
}
