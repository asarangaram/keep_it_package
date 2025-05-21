import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../builders/get_media_view_modifier.dart';

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
        return ShadButton.ghost(
          enabled: viewModifer != null,
          onPressed: viewModifer == null
              ? null
              : () => {
                    viewModifer.onRotate((viewModifer.quarterTurns + 3) % 4),
                  },
          child: const SvgIcon(
            SvgIcons.rotateLeft,
            size: 20,
          ),
        );
      },
    );
  }
}
/* 
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
 */
