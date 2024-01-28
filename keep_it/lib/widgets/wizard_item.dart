import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class WizardItem extends StatelessWidget {
  const WizardItem({
    required this.child,
    this.action,
    super.key,
  });
  final Widget child;
  final CLMenuItem? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: const BorderSide(),
                  left: const BorderSide(),
                  bottom: const BorderSide(),
                  right: action == null ? const BorderSide() : BorderSide.none,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  bottomLeft: const Radius.circular(16),
                  topRight:
                      action == null ? const Radius.circular(16) : Radius.zero,
                  bottomRight:
                      action == null ? const Radius.circular(16) : Radius.zero,
                ),
              ),
              child: child,
            ),
          ),
          if (action != null)
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CLButtonIconLabelled.large(
                    action!.icon,
                    action!.title,
                    onTap: action!.onTap,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
