import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class MissingPreview extends StatelessWidget {
  const MissingPreview({
    required this.media,
    super.key,
  });
  static Widget? placeHolder;

  final CLMedia media;

  @override
  Widget build(BuildContext context) {
    return placeHolder ??= AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox.square(
          dimension: 60 + 16,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Center(
                child: Text(
                  path.basename(media.path),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
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
