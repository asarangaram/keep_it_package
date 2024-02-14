/* import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class MissingPreview extends StatelessWidget {
  const MissingPreview({
    super.key,
  });
  static Widget? placeHolder;

  @override
  Widget build(BuildContext context) {
    return placeHolder ??= AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox.square(
          dimension: 64,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Center(
                child: CLIcon.large(
                  Icons.broken_image_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 */
