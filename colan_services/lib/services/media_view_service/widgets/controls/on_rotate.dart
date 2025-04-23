import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnRotateLeft extends StatelessWidget {
  const OnRotateLeft({
    required this.uri,
    super.key,
  });

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return GetMediaViewModifier(
      uri: uri,
      builder: (viewModifer) {
        {
          return CLButtonIcon.tiny(
            SvgIcons.rotateLeft,
            onTap: viewModifer == null
                ? null
                : () => {
                      viewModifer.onRotate((viewModifer.quarterTurns + 3) % 4),
                    },
            color: ShadTheme.of(context).colorScheme.background,
          );
        }
      },
    );
  }
}

class OnRotateLeft2 extends StatelessWidget {
  const OnRotateLeft2({
    required this.uri,
    super.key,
  });

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return GetMediaViewModifier(
      uri: uri,
      builder: (viewModifer) {
        {
          return CircledSvgIcon(
            SvgIcons.rotateLeft,
            onTap: viewModifer == null
                ? null
                : () => {
                      viewModifer.onRotate((viewModifer.quarterTurns + 3) % 4),
                    },
            color: ShadTheme.of(context).colorScheme.background,
          );
        }
      },
    );
  }
}
