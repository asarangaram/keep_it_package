import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../basics/cl_button.dart';
import '../../extensions/ext_color.dart';
import '../../theme/models/cl_icons.dart';

class CLFullscreenBox extends ConsumerStatefulWidget {
  const CLFullscreenBox({
    required this.child,
    super.key,
    this.useSafeArea = false,
    this.backgroundColor,
    this.hasBorder = false,
    this.backgroundBrightness = 0.25,
    this.hasBackground = true,
    this.bottomNavigationBar,
    this.appBar,
    this.floatingActionButton,
  });

  final Widget child;
  final bool useSafeArea;
  final Color? backgroundColor;
  final bool hasBorder;
  final double backgroundBrightness;
  final bool hasBackground;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CLFullscreenBoxState();
}

class _CLFullscreenBoxState extends ConsumerState<CLFullscreenBox> {
  // Create an overlay entry

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (val) {
        //print('pop invoked $val;');
      },
      child: CLBackground(
        hasBackground: widget.hasBackground,
        backgroundBrightness: widget.backgroundBrightness,
        child: SafeArea(
          top: widget.useSafeArea,
          left: widget.useSafeArea,
          right: widget.useSafeArea,
          bottom: widget.useSafeArea,
          child: ClipRect(
            clipBehavior: Clip.antiAlias,
            child: _ScaffoldBorder(
              hasBorder: widget.hasBorder,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.zero,
                    child: Scaffold(
                      backgroundColor:
                          widget.backgroundColor ?? Colors.transparent,
                      appBar: widget.appBar,
                      body: widget.child,
                      bottomNavigationBar: widget.bottomNavigationBar,
                      floatingActionButton: widget.floatingActionButton,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CLDialogWrapper extends StatelessWidget {
  const CLDialogWrapper({
    required this.child,
    super.key,
    this.isDialog = true,
    this.backgroundColor,
    this.padding,
    this.onCancel,
  });
  final bool isDialog;
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final void Function()? onCancel;
  @override
  Widget build(BuildContext context) {
    if (!isDialog) {
      return WrapCloseButton(
        onCancel: onCancel,
        child: child,
      );
    }
    return Dialog(
      shape: const ContinuousRectangleBorder(),
      //scrollable: true,

      //shape: const ContinuousRectangleBorder(),
      backgroundColor: backgroundColor,
      insetPadding: padding ?? EdgeInsets.zero,
      child: WrapCloseButton(onCancel: onCancel, child: child),
    );
  }
}

class WrapCloseButton extends StatelessWidget {
  const WrapCloseButton({
    required this.child,
    this.onCancel,
    super.key,
  });

  final void Function()? onCancel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onCancel != null)
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                height: 32 + 20,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 16, right: 16, bottom: 16),
                  child: CLButtonIcon.small(
                    clIcons.closeFullscreen,
                    onTap: onCancel,
                  ),
                ),
              ),
            ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _ScaffoldBorder extends StatelessWidget {
  const _ScaffoldBorder({
    required this.hasBorder,
    required this.child,
  });
  final bool hasBorder;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (!hasBorder) return child;
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: child,
    );
  }
}

class CLBackground extends StatelessWidget {
  const CLBackground({
    required this.child,
    super.key,
    this.backgroundBrightness = 0.25,
    this.hasBackground = true,
  });
  final Widget child;
  final double backgroundBrightness;
  final bool hasBackground;

  @override
  Widget build(BuildContext context) {
    if (!hasBackground) return child;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
              ]
                  .map(
                    (e) => backgroundBrightness < 0
                        ? e.reduceBrightness(-backgroundBrightness)
                        : e.increaseBrightness(backgroundBrightness),
                  )
                  .toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
