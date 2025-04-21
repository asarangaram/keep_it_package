import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum SvgIcons {
  rotateLeft('rotate-left-19'),
  rotateRight('rotate-right-18');

  const SvgIcons(this.slug);
  final String slug;

  String get assetPath => 'assets/icon/svg/$slug.svg';
}

class SvgIcon extends StatelessWidget {
  const SvgIcon(
    this.data, {
    super.key,
    this.color,
    this.size,
  });
  final Color? color;
  final double? size;
  final SvgIcons data;
  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    return SvgPicture.asset(
      data.assetPath,
      colorFilter: ColorFilter.mode(color ?? iconTheme.color!, BlendMode.srcIn),
      height: size ?? iconTheme.size,
      width: size ?? iconTheme.size,
    );
  }
}
