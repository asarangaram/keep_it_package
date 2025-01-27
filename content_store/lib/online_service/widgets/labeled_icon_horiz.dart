import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';

class LabeledIconHorizontal extends StatelessWidget {
  const LabeledIconHorizontal(
    this.menuItem, {
    super.key,
  }) : isHazard = false;
  const LabeledIconHorizontal.dangerous(
    this.menuItem, {
    super.key,
  }) : isHazard = true;

  final CLMenuItem menuItem;
  final bool isHazard;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: menuItem.onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isHazard
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context)
                  .colorScheme
                  .primary, // ElevatedButton background color
          borderRadius:
              BorderRadius.circular(8), // Rounded corners like ElevatedButton
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.2,
              ), // Slight shadow to simulate elevation
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // Shrinks the container to the content size
            children: [
              Icon(menuItem.icon, color: Colors.white), // Icon with white color
              const SizedBox(width: 8), // Space between icon and text
              Text(
                menuItem.title,
                style: TextStyle(
                  color: isHazard
                      ? Theme.of(context).colorScheme.error
                      : Colors.white,
                ), // White text to match the button style
              ),
            ],
          ),
        ),
      ),
    );
  }
}
